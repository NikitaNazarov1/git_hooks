# frozen_string_literal: true

module GitHooks
  module Checks
    module PostCheckout
      class NpmInstall < Base
        include NpmInstallCheck

        check_definition key: 'npm-install',
                         hook: :post_checkout,
                         description: 'Run npm install when package.json or package-lock.json changed (branch checkout)',
                         **NpmInstallCheck::DEFINITION_OPTIONS
      end
    end
  end
end
