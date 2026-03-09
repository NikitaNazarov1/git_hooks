# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.7.2]

### Added

- **post-checkout hook** — Runs after branch checkout. Includes `bundle-install` (run `bundle install` when Gemfile/Gemfile.lock changed) and `db-migrate` (run `rails db:migrate` when migrations or schema changed). Both enabled by default.
- **post-merge hook** — Runs after merge. Same checks as post-checkout: `bundle-install` and `db-migrate`, enabled by default. Keeps the app bundled and migrated when pulling or merging (inspired by [hookup](https://rubygems.org/gems/hookup)).
- **Shared check modules** — `checks/shared/bundle_install_check.rb` and `checks/shared/db_migrate_check.rb` hold common logic and options for the post-checkout and post-merge bundle/migrate checks.
- **Specs for every check** — RSpec examples for all 13 checks (pre-commit, commit-msg, pre-push, post-checkout, post-merge) under `spec/rails_git_hooks/checks/`.

### Changed

- **Default install** — With no config file, `install` now installs **commit-msg**, **pre-commit**, **post-checkout**, and **post-merge** (post-checkout/post-merge bundle and db-migrate checks are on by default).
- **Runner** — `modified_files` now supports `post_checkout` (files changed between refs on branch checkout) and `post_merge` (files changed between ORIG_HEAD and HEAD). Repository adds `changed_files(ref1, ref2)`.
- **defaults.yml** — PostCheckout and PostMerge sections: `BundleInstall` and `DbMigrate` set to `enabled: true` by default.

## [0.7.1]

### Added

- **Code-first runtime architecture** — Hook behavior now lives in Ruby classes with a central runner, registry, policy resolver, dependency checker, and sparse override config loader.
- **Sparse override config** — Added optional `.rails_git_hooks.yml` with Overcommit-style per-check overrides for `enabled`, `quiet`, `on_fail`, `on_warn`, `on_missing_dependency`, `include`, `exclude`, and `command`.
- **Thin hook bootstraps** — `templates/hooks/*` now dispatch into the embedded `rails_git_hooks` runtime instead of loading copied script files per check.
- **Pre-commit YAML format check** — Warns (does not block) when any staged `.yml` or `.yaml` file fails to parse (invalid YAML). Reports file and line from the parser. On by default with pre-commit.
- **Pre-commit JSON format check** — Warns (does not block) when any staged `.json` file fails to parse (invalid JSON). Reports file and parser message. On by default with pre-commit.
- **Pre-commit migrations check** — Warns (does not block) when: (a) migration file(s) are staged but neither `db/schema.rb` nor `db/structure.sql` is staged; (b) data migration file(s) in `db/data/` or `db/data_migrate/` are staged but `db/data_schema.rb` is not. **On by default.** Disable with `rails_git_hooks disable migrations-check`.
- **Defaults YAML** — `lib/rails_git_hooks/config/defaults.yml` holds default settings for every check and hook. `DefaultsLoader` reads it; `OverrideConfig` uses it as the base when merging with `.rails_git_hooks.yml`. Edit the YAML to change built-in defaults.

### Changed

- **CLI redesign** — Replaced per-check flag-file commands with generic config-driven commands: `install`, `list`, `init`, `enable`, `disable`, `set`, and `show-config`.
- **Manual install layout** — Manual install is via `bundle exec rails_git_hooks install` only; dropped `rake sync_hooks` and the repo `hooks/` tree.
- **Dependency handling** — Checks can now declare executables, Ruby libraries, files, and install hints, with centralized `on_missing_dependency` policy handling.
- **Runtime install** — Installer copies all runtime files (including `config/defaults.yml`), not only `*.rb`, into `.git/hooks/rails_git_hooks/`.
- **Removed `hooks/` directory** — `/hooks/` added to `.gitignore`. README manual-install section updated.

## [0.7.0]

### Changed

- **Overcommit-style layout:** Hook templates live in `templates/hooks/` (was `lib/rails_git_hooks/templates/`). `rake sync_hooks` copies them to `hooks/` for manual install.
- **Constants:** Extracted `lib/rails_git_hooks/constants.rb` (GEM_ROOT, HOOKS_DIR, DEFAULT_HOOKS, FEATURE_FLAG_FILES). Installer and CLI use it. Single source of truth; no config file.
- Gemspec includes `templates/**/*`. Version set to 0.7.0.

## [0.6.1]

### Changed

- **Default install** now installs **commit-msg** and **pre-commit** only (Jira ticket prefix + default-branch protection; RuboCop opt-in). Pre-push remains opt-in: `rails_git_hooks install pre-push`.
- README: quick start and commands table updated for default (commit-msg + pre-commit); Jira project key / `JIRA_PROJECT_KEY` for manual install; pre-push install instruction.

## [0.6.0]

### Added

- **Trailing whitespace / conflict markers** check in pre-commit (disabled by default): rejects commits that add trailing spaces/tabs or `<<<<<<<` / `=======` / `>>>>>>>` in staged files. Enable with `rails_git_hooks enable whitespace-check`; disable with `rails_git_hooks disable whitespace-check`.

## [0.5.0]

### Added

- **pre-push** hook: runs `bundle exec rspec` before every push; aborts push if tests fail. Respects `rails_git_hooks_disabled`.
- RuboCop `Lint/ScriptPermission` exclusion for `hooks/*` (same as templates).

## [0.4.1]

### Changed

- Gemspec: updated summary for RubyGems listing

## [0.4.0]

### Changed

- Gem and project renamed to **rails_git_hooks** (from `git_hooks`)
- Library: `lib/git_hooks/` → `lib/rails_git_hooks/`; entry point `lib/rails_git_hooks.rb`
- CLI executable: `rails_git_hooks` (replaces `git_hooks`)
- Disabled state file: `.git/rails_git_hooks_disabled` (was `.git/git_hooks_disabled`)
- README, docs, and in-repo paths updated for `rails_git_hooks`

### Added

- RuboCop `Lint/ScriptPermission` exclusion for `lib/rails_git_hooks/templates/*` (templates are made executable at install time)

## [0.3.0]

### Fixed

- fixed versioning

## [0.2.0]

### Added

- RSpec test suite for CLI and Installer
- `rake sync_hooks` task to copy templates from `lib/git_hooks/templates` to `hooks/` for manual install
- Gemspec metadata: `source_code_uri`, `changelog_uri`; author email
- CHANGELOG.md (Keep a Changelog format)
- Default Rake task runs specs (`rake` = `rake spec`)

### Changed

- **Single source of truth:** `lib/git_hooks/templates/` is canonical; `hooks/` kept in sync via `rake sync_hooks`
- CLI install: `--jira` parsed with OptionParser instead of manual loop
- Installer `#disable`: simplified to `(disabled_hooks + hook_names).uniq`
- Hooks: commit-msg and pre-commit now include disable check (`.git/rails_git_hooks_disabled`); commit-msg uses `JIRA_PROJECT_KEY` placeholder for manual install
- pre-commit: use `warn` instead of `$stderr.puts` for default-branch message
- README: manual install points to `hooks/` and `JIRA_PROJECT_KEY`; development section documents `rake`, `rake sync_hooks`

### Fixed

- (none)

## [0.1.0] - (initial release)

- commit-msg hook: Jira ticket prefix in commit messages
- pre-commit hook: RuboCop on staged Ruby files, block commits on default branch (master/main)
- `rails_git_hooks install`, `disable`, `enable`, `disabled`, `list` CLI commands
