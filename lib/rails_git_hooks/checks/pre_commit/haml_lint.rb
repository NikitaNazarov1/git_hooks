# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class HamlLint < Base
        check_definition key: 'haml-lint-check',
                         hook: :pre_commit,
                         description: 'Run haml-lint on staged HAML files',
                         file_based: true,
                         enabled: false,
                         quiet: true,
                         dependencies: { 'executables' => ['bundle'], 'libraries' => ['haml_lint'] },
                         command: %w[bundle exec haml-lint],
                         install_hint: 'Add `gem "haml_lint"` to your Gemfile and run bundle install'

        def run
          haml_files = applicable_files.select { |path| path.end_with?('.haml') && File.file?(path) }
          return CheckResult.pass if haml_files.empty?

          output, status = capture(*Array(config['command']), *haml_files)
          return CheckResult.pass if status.success?

          messages = output.split("\n").map(&:rstrip).reject(&:empty?)
          CheckResult.fail(messages: messages)
        end
      end
    end
  end
end
