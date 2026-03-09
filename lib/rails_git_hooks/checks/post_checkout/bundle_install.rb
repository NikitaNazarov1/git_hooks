# frozen_string_literal: true

module GitHooks
  module Checks
    module PostCheckout
      class BundleInstall < Base
        include BundleInstallCheck

        check_definition key: 'bundle-install',
                         hook: :post_checkout,
                         description: 'Run bundle install when Gemfile or Gemfile.lock changed (branch checkout)',
                         **BundleInstallCheck::DEFINITION_OPTIONS
      end
    end
  end
end
