# frozen_string_literal: true

# Warns when migration/data_migration file(s) are staged but the corresponding schema file is not.
# On by default; disable with rails_git_hooks disable migrations-check.
# Suggests running the migrate task and adding the schema file. Does not block the commit.
# Expects RailsGitHooks::GIT_DIR to be set by the loader.

git_dir = RailsGitHooks::GIT_DIR
disabled_file = File.join(git_dir, 'rails_git_hooks_migrations_check_disabled')
unless File.exist?(disabled_file)
  staged = `git diff --cached --name-only`.split("\n").map(&:strip).reject(&:empty?)

  # Schema migrations: db/migrate/*.rb -> db/schema.rb or db/structure.sql
  migration_files = staged.grep(%r{\Adb/migrate/.*\.rb\z})
  schema_staged = staged.include?('db/schema.rb') || staged.include?('db/structure.sql')
  if migration_files.any? && !schema_staged
    warn ''
    warn 'Warning (migrations check):'
    warn '  Migration file(s) are staged but neither db/schema.rb nor db/structure.sql is staged.'
    warn '  Run `rails db:migrate` and add db/schema.rb (or db/structure.sql) to your commit.'
    migration_files.each { |f| warn "  - #{f}" }
    warn ''
  end

  # Data migrations: db/data/*.rb or db/data_migrate/*.rb -> db/data_schema.rb
  data_migration_files = staged.grep(%r{\Adb/(data/|data_migrate/).*\.rb\z})
  data_schema_staged = staged.include?('db/data_schema.rb')
  if data_migration_files.any? && !data_schema_staged
    warn ''
    warn 'Warning (migrations check):'
    warn '  Data migration file(s) are staged but db/data_schema.rb is not staged.'
    warn '  Run your data migrate task and add db/data_schema.rb to your commit.'
    data_migration_files.each { |f| warn "  - #{f}" }
    warn ''
  end
end
