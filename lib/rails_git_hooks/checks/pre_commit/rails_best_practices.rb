# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class RailsBestPractices < Base
        check_definition key: 'rails-best-practices',
                         hook: :pre_commit,
                         description: 'Warn on Rails best practices violations',
                         file_based: true,
                         enabled: false,
                         on_fail: :warn,
                         quiet: true,
                         dependencies: { 'executables' => ['bundle'], 'libraries' => ['rails_best_practices'] },
                         command: %w[bundle exec rails_best_practices],
                         install_hint: 'Add `gem "rails_best_practices"` to your Gemfile and run bundle install'

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
