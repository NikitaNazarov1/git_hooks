# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class RuboCop < Base
        check_definition key: 'rubocop-check',
                         hook: :pre_commit,
                         description: 'Run RuboCop on staged Ruby files',
                         file_based: true,
                         enabled: false,
                         quiet: true,
                         dependencies: { 'executables' => ['bundle'], 'libraries' => ['rubocop'] },
                         command: %w[bundle exec rubocop],
                         install_hint: 'Add `gem "rubocop"` to your Gemfile and run bundle install'

        def run
          ruby_files = applicable_files.select { |path| File.extname(path) == '.rb' && File.file?(path) }
          return CheckResult.pass if ruby_files.empty?

          output, status = capture(*Array(config['command']), *ruby_files)
          return CheckResult.pass if status.success?

          messages = output.split("\n").map(&:rstrip).reject(&:empty?)
          CheckResult.fail(messages: messages)
        end
      end
    end
  end
end
