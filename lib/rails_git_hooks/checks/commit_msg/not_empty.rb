# frozen_string_literal: true

module GitHooks
  module Checks
    module CommitMsg
      class NotEmpty < Base
        check_definition key: 'not-empty',
                         hook: :commit_msg,
                         description: 'Reject empty commit messages'

        def run
          message_file = argv.first
          return CheckResult.pass unless message_file && File.file?(message_file)

          message = File.read(message_file)
          # Strip comment lines (git uses # in the message template) and blank lines
          content = message.lines.reject { |line| line.strip.start_with?('#') || line.strip.empty? }.join.strip
          return CheckResult.pass unless content.empty?

          CheckResult.fail(messages: ['Commit message must not be empty.'])
        end
      end
    end
  end
end
