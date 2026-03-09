# frozen_string_literal: true

module GitHooks
  module Checks
    # Shared logic and options for "run db:migrate when migrations or schema changed"
    # (post-checkout and post-merge). Each hook has its own class that passes hook + description.
    module DbMigrateCheck
      DEFINITION_OPTIONS = {
        file_based: true,
        enabled: false,
        include: ['db/migrate/*.rb', 'db/schema.rb', 'db/structure.sql'],
        dependencies: { executables: ['bundle'] },
        command: %w[bundle exec rails db:migrate],
        install_hint: 'Rails app with db:migrate (or override command in config)'
      }.freeze

      def run
        return CheckResult.pass if applicable_files.empty?

        output, status = capture(*Array(config['command']))
        return CheckResult.pass if status.success?

        messages = output.split("\n").map(&:rstrip).reject(&:empty?)
        CheckResult.fail(messages: messages)
      end
    end
  end
end
