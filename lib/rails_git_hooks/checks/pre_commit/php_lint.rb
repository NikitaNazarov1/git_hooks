# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class PhpLint < Base
        check_definition key: 'php-lint-check',
                         hook: :pre_commit,
                         description: 'Run php -l (syntax check) on staged PHP files',
                         file_based: true,
                         enabled: false,
                         quiet: true,
                         dependencies: { 'executables' => ['php'] },
                         command: %w[php -l],
                         install_hint: 'Ensure PHP is installed and on PATH'

        def run
          php_files = applicable_files.select { |path| path.end_with?('.php') && File.file?(path) }
          return CheckResult.pass if php_files.empty?

          output, status = capture(*Array(config['command']), *php_files)
          return CheckResult.pass if status.success?

          messages = output.split("\n").map(&:rstrip).reject(&:empty?)
          CheckResult.fail(messages: messages)
        end
      end
    end
  end
end
