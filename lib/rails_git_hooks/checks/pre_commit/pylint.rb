# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class Pylint < Base
        check_definition key: 'pylint-check',
                         hook: :pre_commit,
                         description: 'Run pylint on staged Python files',
                         file_based: true,
                         enabled: false,
                         quiet: true,
                         dependencies: { 'executables' => ['pylint'] },
                         command: %w[pylint],
                         install_hint: 'Install pylint (e.g. pip install pylint) or override command in config'

        def run
          py_files = applicable_files.select { |path| path.end_with?('.py') && File.file?(path) }
          return CheckResult.pass if py_files.empty?

          output, status = capture(*Array(config['command']), *py_files)
          return CheckResult.pass if status.success?

          messages = output.split("\n").map(&:rstrip).reject(&:empty?)
          CheckResult.fail(messages: messages)
        end
      end
    end
  end
end
