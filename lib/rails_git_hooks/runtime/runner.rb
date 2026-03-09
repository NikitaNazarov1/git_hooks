# frozen_string_literal: true

module GitHooks
  class Runner
    def initialize(repo:, hook_name:, argv:, stdin:)
      @repo = repo
      @hook_name = hook_name.to_sym
      @argv = argv
      @stdin = stdin
      @overrides = OverrideConfig.new(repo: repo)
      @dependencies = DependencyChecker.new(repo: repo)
      @policy = PolicyResolver.new
    end

    def run
      failed = false

      CheckRegistry.for(@hook_name).each do |definition|
        config = @overrides.config_for(definition)
        next unless config['enabled']

        context = {
          repo: @repo,
          argv: @argv,
          stdin: @stdin,
          applicable_files: applicable_files_for(config)
        }

        raw_result = @dependencies.check(config)
        raw_result = definition.klass.new(config: config, context: context).run if raw_result.pass?
        final_result = @policy.resolve(raw_result, config)

        print_result(definition, final_result, quiet: config['quiet'])
        failed ||= final_result.fail?
      end

      failed ? 1 : 0
    end

    private

    def applicable_files_for(config)
      return [] unless config['file_based']

      FileMatcher.filter(
        modified_files,
        include_patterns: Array(config['include']),
        exclude_patterns: Array(config['exclude'])
      )
    end

    def modified_files
      @modified_files ||= case @hook_name
                          when :pre_commit then @repo.staged_files
                          when :post_checkout
                            argv[2] == '1' ? @repo.changed_files(argv[0], argv[1]) : []
                          when :post_merge
                            @repo.changed_files('ORIG_HEAD', 'HEAD')
                          else []
                          end
    end

    def print_result(definition, result, quiet:)
      return if result.pass? && quiet
      return if result.pass? && result.messages.empty?

      case result.status
      when :warn
        warn ''
        warn "Warning (#{definition.config_name}):"
      when :fail
        warn ''
        warn "Commit rejected (#{definition.config_name}):"
      end

      result.messages.each { |message| warn "  #{message}" } unless result.pass?
      warn '' unless result.pass?
    end
  end
end
