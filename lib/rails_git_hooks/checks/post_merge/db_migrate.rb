# frozen_string_literal: true

module GitHooks
  module Checks
    module PostMerge
      class DbMigrate < Base
        include DbMigrateCheck

        check_definition key: 'db-migrate',
                         hook: :post_merge,
                         description: 'Run db:migrate when migrations or schema changed (after merge)',
                         **DbMigrateCheck::DEFINITION_OPTIONS
      end
    end
  end
end
