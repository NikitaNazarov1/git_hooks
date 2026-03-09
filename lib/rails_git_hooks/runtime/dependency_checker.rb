# frozen_string_literal: true

module GitHooks
  class DependencyChecker
    def initialize(repo:)
      @repo = repo
    end

    def check(config)
      dependencies = config.fetch('dependencies', {})
      missing = []

      Array(dependencies['executables']).each do |name|
        missing << "missing executable: #{name}" unless executable_available?(name)
      end

      Array(dependencies['libraries']).each do |name|
        missing << "missing library: #{name}" unless library_available?(name)
      end

      Array(dependencies['files']).each do |name|
        path = File.expand_path(name, @repo.root)
        missing << "missing file: #{name}" unless File.exist?(path)
      end

      return CheckResult.pass if missing.empty?

      hint = config['install_hint']
      messages = missing.dup
      messages << hint if hint && !hint.empty?
      CheckResult.fail(messages: messages, reason: :missing_dependency)
    end

    private

    def executable_available?(name)
      return File.executable?(File.expand_path(name, @repo.root)) if name.include?(File::SEPARATOR)

      ENV.fetch('PATH', '').split(File::PATH_SEPARATOR).any? do |dir|
        File.executable?(File.join(dir, name))
      end
    end

    def library_available?(name)
      require name
      true
    rescue LoadError
      false
    end
  end
end
