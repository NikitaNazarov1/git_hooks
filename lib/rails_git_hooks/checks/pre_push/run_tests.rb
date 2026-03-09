# frozen_string_literal: true

module GitHooks
  module Checks
    module PrePush
      class RunTests < Base
        check_definition key: 'run-tests',
                         hook: :pre_push,
                         description: 'Run test suite before push',
                         dependencies: { 'executables' => ['bundle'] },
                         command: %w[bundle exec rspec],
                         install_hint: 'Install test dependencies and ensure `bundle exec rspec` runs successfully'

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
