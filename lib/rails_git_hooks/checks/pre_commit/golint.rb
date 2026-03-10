# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class Golint < Base
        check_definition key: 'golint-check',
                         hook: :pre_commit,
                         description: 'Run golint on staged Go files',
                         file_based: true,
                         enabled: false,
                         quiet: true,
                         dependencies: { 'executables' => ['golint'] },
                         command: %w[golint],
                         install_hint: 'Install golint or override command in config'

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
