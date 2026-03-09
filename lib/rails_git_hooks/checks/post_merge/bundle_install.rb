# frozen_string_literal: true

module GitHooks
  module Checks
    module PostMerge
      class BundleInstall < Base
        include BundleInstallCheck

        check_definition key: 'bundle-install',
                         hook: :post_merge,
                         description: 'Run bundle install when Gemfile or Gemfile.lock changed (after merge)',
                         **BundleInstallCheck::DEFINITION_OPTIONS
      end
    end
  end
end
