# frozen_string_literal: true

module GitHooks
  module Checks
    module PostCheckout
      class YarnInstall < Base
        include YarnInstallCheck

        check_definition key: 'yarn-install',
                         hook: :post_checkout,
                         description: 'Run yarn install when package.json or yarn.lock changed (branch checkout)',
                         **YarnInstallCheck::DEFINITION_OPTIONS
      end
    end
  end
end
