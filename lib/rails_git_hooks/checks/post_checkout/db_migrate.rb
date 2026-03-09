# frozen_string_literal: true

module GitHooks
  module Checks
    module PostCheckout
      class DbMigrate < Base
        include DbMigrateCheck

        check_definition key: 'db-migrate',
                         hook: :post_checkout,
                         description: 'Run db:migrate when migrations or schema changed (branch checkout)',
                         **DbMigrateCheck::DEFINITION_OPTIONS
      end
    end
  end
end
