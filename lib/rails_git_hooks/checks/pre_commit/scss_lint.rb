# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class ScssLint < Base
        check_definition key: 'scss-lint-check',
                         hook: :pre_commit,
                         description: 'Run scss-lint on staged SCSS files',
                         file_based: true,
                         enabled: false,
                         quiet: true,
                         dependencies: { 'executables' => ['bundle'], 'libraries' => ['scss_lint'] },
                         command: %w[bundle exec scss-lint],
                         install_hint: 'Add `gem "scss_lint"` to your Gemfile and run bundle install'

        def run
          scss_files = applicable_files.select { |path| path.end_with?('.scss') && File.file?(path) }
          return CheckResult.pass if scss_files.empty?

          output, status = capture(*Array(config['command']), *scss_files)
          return CheckResult.pass if status.success?

          messages = output.split("\n").map(&:rstrip).reject(&:empty?)
          CheckResult.fail(messages: messages)
        end
      end
    end
  end
end
