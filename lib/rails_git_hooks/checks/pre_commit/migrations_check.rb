# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class MigrationsCheck < Base
        check_definition key: 'migrations-check',
                         hook: :pre_commit,
                         description: 'Warn on missing schema files after migrations',
                         file_based: true,
                         on_fail: :warn

        def run
          messages = []
          migration_files = applicable_files.grep(%r{\Adb/migrate/.*\.rb\z})
          schema_staged = applicable_files.include?('db/schema.rb') || applicable_files.include?('db/structure.sql')

          if migration_files.any? && !schema_staged
            messages << 'Migration file(s) are staged but neither db/schema.rb nor db/structure.sql is staged.'
            messages << 'Run `rails db:migrate` and add db/schema.rb (or db/structure.sql) to your commit.'
            migration_files.each { |path| messages << "- #{path}" }
          end

          data_migration_files = applicable_files.grep(%r{\Adb/(data/|data_migrate/).*\.rb\z})
          data_schema_staged = applicable_files.include?('db/data_schema.rb')
          if data_migration_files.any? && !data_schema_staged
            messages << 'Data migration file(s) are staged but db/data_schema.rb is not staged.'
            messages << 'Run your data migrate task and add db/data_schema.rb to your commit.'
            data_migration_files.each { |path| messages << "- #{path}" }
          end

          messages.empty? ? CheckResult.pass : CheckResult.fail(messages: messages)
        end
      end
    end
  end
end
