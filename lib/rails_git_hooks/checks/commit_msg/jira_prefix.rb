# frozen_string_literal: true

module GitHooks
  module Checks
    module CommitMsg
      class JiraPrefix < Base
        TICKET_PATTERN = /([A-Z]{2,5}-(X+|\d+))/i.freeze

        check_definition key: 'jira-prefix',
                         hook: :commit_msg,
                         description: 'Prefix commit messages with ticket id from branch'

        def run
          message_file = argv.first
          return CheckResult.pass unless message_file && File.file?(message_file)

          branch = repo.current_branch
          ticket = branch[TICKET_PATTERN, 1]
          return CheckResult.pass unless ticket

          message = File.read(message_file)
          prefix = "[#{ticket}]"
          return CheckResult.pass if message.lstrip.start_with?(prefix)

          File.write(message_file, "#{prefix} #{message}")
          CheckResult.pass
        end
      end
    end
  end
end
