# frozen_string_literal: true

module GitHooks
  module Checks
    module PrePush
      class RunGoTest < Base
        check_definition key: 'run-go-test',
                         hook: :pre_push,
                         description: 'Run go test suite before push',
                         dependencies: { 'executables' => ['go'] },
                         command: %w[go test ./...],
                         install_hint: 'Ensure Go toolchain is installed and `go test ./...` runs successfully'

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
