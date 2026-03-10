# frozen_string_literal: true

module GitHooks
  module Checks
    module PostMerge
      class NpmInstall < Base
        include NpmInstallCheck

        check_definition key: 'npm-install',
                         hook: :post_merge,
                         description: 'Run npm install when package.json or package-lock.json changed (after merge)',
                         **NpmInstallCheck::DEFINITION_OPTIONS
      end
    end
  end
end
