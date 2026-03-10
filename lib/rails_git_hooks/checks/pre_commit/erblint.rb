# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class ErbLint < Base
        check_definition key: 'erblint-check',
                         hook: :pre_commit,
                         description: 'Run erblint on staged ERB files',
                         file_based: true,
                         enabled: false,
                         quiet: true,
                         dependencies: { 'executables' => ['bundle'], 'libraries' => ['erblint'] },
                         command: %w[bundle exec erblint],
                         install_hint: 'Add `gem "erblint"` to your Gemfile and run bundle install'

        def run
          erb_files = applicable_files.select { |path| path.end_with?('.erb') && File.file?(path) }
          return CheckResult.pass if erb_files.empty?

          output, status = capture(*Array(config['command']), *erb_files)
          return CheckResult.pass if status.success?

          messages = output.split("\n").map(&:rstrip).reject(&:empty?)
          CheckResult.fail(messages: messages)
        end
      end
    end
  end
end
