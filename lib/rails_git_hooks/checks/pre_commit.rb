# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class DefaultBranch < Base
        check_definition key: 'default-branch',
                         hook: :pre_commit,
                         description: 'Prevent commits on default branch'

        def run
          branch = repo.current_branch
          return CheckResult.pass unless %w[master main].include?(branch)

          CheckResult.fail(messages: ["Commits on '#{branch}' are not allowed. Create a feature branch."])
        end
      end

      class DebuggerCheck < Base
        DEBUGGER_PATTERNS = {
          '.rb' => [/\bbinding\.pry\b/, /\bbinding\.irb\b/, /\bdebugger\b/, /\bbyebug\b/],
          '.js' => [/\bdebugger\s*;?/],
          '.jsx' => [/\bdebugger\s*;?/],
          '.ts' => [/\bdebugger\s*;?/],
          '.tsx' => [/\bdebugger\s*;?/],
          '.mjs' => [/\bdebugger\s*;?/],
          '.cjs' => [/\bdebugger\s*;?/],
          '.py' => [/\bbreakpoint\s*\(\s*\)/, /\bpdb\.set_trace\s*\(\s*\)/, /\bipdb\.set_trace\s*\(\s*\)/]
        }.freeze

        check_definition key: 'debugger-check',
                         hook: :pre_commit,
                         description: 'Warn on debugger statements',
                         file_based: true,
                         on_fail: :warn

        def run
          warnings = []

          applicable_files.each do |path|
            next unless File.file?(path)

            patterns = DEBUGGER_PATTERNS[File.extname(path)]
            next unless patterns

            File.read(path).lines.each_with_index do |line, index|
              warnings << "#{path}:#{index + 1}: debugger statement" if patterns.any? { |pattern| line.match?(pattern) }
            end
          end

          warnings.empty? ? CheckResult.pass : CheckResult.fail(messages: warnings.uniq)
        end
      end

      class YAMLFormatCheck < Base
        check_definition key: 'yaml-format-check',
                         hook: :pre_commit,
                         description: 'Warn on invalid YAML',
                         file_based: true,
                         on_fail: :warn

        def run
          warnings = []

          applicable_files.each do |path|
            next unless File.file?(path)
            next unless %w[.yml .yaml].include?(File.extname(path))

            YAML.load_file(path)
          rescue Psych::SyntaxError => e
            location = e.line ? "#{path}:#{e.line}" : path
            warnings << "#{location}: #{e.message}"
          end

          warnings.empty? ? CheckResult.pass : CheckResult.fail(messages: warnings)
        end
      end

      class JSONFormatCheck < Base
        check_definition key: 'json-format-check',
                         hook: :pre_commit,
                         description: 'Warn on invalid JSON',
                         file_based: true,
                         on_fail: :warn

        def run
          warnings = []

          applicable_files.each do |path|
            next unless File.file?(path)
            next unless File.extname(path) == '.json'

            JSON.parse(File.read(path))
          rescue JSON::ParserError => e
            warnings << "#{path}: #{e.message}"
          end

          warnings.empty? ? CheckResult.pass : CheckResult.fail(messages: warnings)
        end
      end

      class MigrationsCheck < Base
        check_definition key: 'migrations-check',
                         hook: :pre_commit,
                         description: 'Warn on missing schema files after migrations',
                         file_based: true,
                         on_fail: :warn

        def run
          messages = []
          migration_files = applicable_files.grep(%r{\Adb/migrate/.*\.rb\z})
          schema_staged = applicable_files.include?('db/schema.rb') || applicable_files.include?('db/structure.sql')

          if migration_files.any? && !schema_staged
            messages << 'Migration file(s) are staged but neither db/schema.rb nor db/structure.sql is staged.'
            messages << 'Run `rails db:migrate` and add db/schema.rb (or db/structure.sql) to your commit.'
            migration_files.each { |path| messages << "- #{path}" }
          end

          data_migration_files = applicable_files.grep(%r{\Adb/(data/|data_migrate/).*\.rb\z})
          data_schema_staged = applicable_files.include?('db/data_schema.rb')
          if data_migration_files.any? && !data_schema_staged
            messages << 'Data migration file(s) are staged but db/data_schema.rb is not staged.'
            messages << 'Run your data migrate task and add db/data_schema.rb to your commit.'
            data_migration_files.each { |path| messages << "- #{path}" }
          end

          messages.empty? ? CheckResult.pass : CheckResult.fail(messages: messages)
        end
      end

      class WhitespaceCheck < Base
        check_definition key: 'whitespace-check',
                         hook: :pre_commit,
                         description: 'Reject trailing whitespace and conflict markers',
                         file_based: true,
                         enabled: false

        def run
          errors = []

          applicable_files.each do |path|
            next unless File.file?(path)

            File.read(path).lines.each_with_index do |line, index|
              errors << "#{path}:#{index + 1}: trailing whitespace" if line.match?(/[ \t]\z/)
              stripped = line.strip
              errors << "#{path}:#{index + 1}: conflict marker" if stripped.start_with?('<<<<<<<', '=======', '>>>>>>>')
            end
          end

          errors.empty? ? CheckResult.pass : CheckResult.fail(messages: errors.uniq)
        end
      end

      class RuboCop < Base
        check_definition key: 'rubocop-check',
                         hook: :pre_commit,
                         description: 'Run RuboCop on staged Ruby files',
                         file_based: true,
                         enabled: false,
                         quiet: true,
                         dependencies: { 'executables' => ['bundle'], 'libraries' => ['rubocop'] },
                         command: %w[bundle exec rubocop],
                         install_hint: 'Add `gem "rubocop"` to your Gemfile and run bundle install'

        def run
          ruby_files = applicable_files.select { |path| File.extname(path) == '.rb' && File.file?(path) }
          return CheckResult.pass if ruby_files.empty?

          output, status = capture(*Array(config['command']), *ruby_files)
          return CheckResult.pass if status.success?

          messages = output.split("\n").map(&:rstrip).reject(&:empty?)
          CheckResult.fail(messages: messages)
        end
      end
    end
  end
end
