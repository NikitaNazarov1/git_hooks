# frozen_string_literal: true

module GitHooks
  module Checks
    module PostMerge
      class YarnInstall < Base
        include YarnInstallCheck

        check_definition key: 'yarn-install',
                         hook: :post_merge,
                         description: 'Run yarn install when package.json or yarn.lock changed (after merge)',
                         **YarnInstallCheck::DEFINITION_OPTIONS
      end
    end
  end
end
