# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class DefaultBranch < Base
        check_definition key: 'default-branch',
                         hook: :pre_commit,
                         description: 'Prevent commits on default branch'

        def run
          branch = repo.current_branch
          return CheckResult.pass unless %w[master main].include?(branch)

          CheckResult.fail(messages: ["Commits on '#{branch}' are not allowed. Create a feature branch."])
        end
      end
    end
  end
end
