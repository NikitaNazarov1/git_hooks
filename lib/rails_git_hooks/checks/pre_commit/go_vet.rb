# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class GoVet < Base
        check_definition key: 'go-vet-check',
                         hook: :pre_commit,
                         description: 'Run go vet on staged Go files',
                         file_based: true,
                         enabled: false,
                         quiet: true,
                         dependencies: { 'executables' => ['go'] },
                         command: %w[go vet],
                         install_hint: 'Ensure Go toolchain is installed and on PATH'

        def run
          go_files = applicable_files.select { |path| File.file?(path) && File.extname(path) == '.go' }
          return CheckResult.pass if go_files.empty?

          output, status = capture(*Array(config['command']), *go_files)
          return CheckResult.pass if status.success?

          messages = output.split("\n").map(&:rstrip).reject(&:empty?)
          CheckResult.fail(messages: messages)
        end
      end
    end
  end
end
