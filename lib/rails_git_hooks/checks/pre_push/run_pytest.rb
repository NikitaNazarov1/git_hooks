# frozen_string_literal: true

module GitHooks
  module Checks
    module PrePush
      class RunPytest < Base
        check_definition key: 'run-pytest',
                         hook: :pre_push,
                         description: 'Run pytest test suite before push',
                         dependencies: { 'executables' => ['pytest'] },
                         command: %w[pytest],
                         install_hint: 'Install pytest (e.g. pip install pytest) and ensure pytest runs successfully'

        def run
          output, status = capture(*Array(config['command']))
          return CheckResult.pass if status.success?

          messages = output.split("\n").map(&:rstrip).reject(&:empty?)
          CheckResult.fail(messages: messages)
        end
      end
    end
  end
end
