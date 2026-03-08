# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## Unrelised

### Added

- **Code-first runtime architecture** — Hook behavior now lives in Ruby classes with a central runner, registry, policy resolver, dependency checker, and sparse override config loader.
- **Sparse override config** — Added optional `.rails_git_hooks.yml` with Overcommit-style per-check overrides for `enabled`, `quiet`, `on_fail`, `on_warn`, `on_missing_dependency`, `include`, `exclude`, and `command`.
- **Thin hook bootstraps** — `templates/hooks/*` now dispatch into the embedded `rails_git_hooks` runtime instead of loading copied script files per check.
- **Pre-commit YAML format check** — Warns (does not block) when any staged `.yml` or `.yaml` file fails to parse (invalid YAML). Reports file and line from the parser. On by default with pre-commit.
- **Pre-commit JSON format check** — Warns (does not block) when any staged `.json` file fails to parse (invalid JSON). Reports file and parser message. On by default with pre-commit.
- **Pre-commit migrations check** — Warns (does not block) when: (a) migration file(s) are staged but neither `db/schema.rb` nor `db/structure.sql` is staged; (b) data migration file(s) in `db/data/` or `db/data_migrate/` are staged but `db/data_schema.rb` is not. **On by default.** Disable with `rails_git_hooks disable migrations-check`.

### Changed

- **CLI redesign** — Replaced per-check flag-file commands with generic config-driven commands: `install`, `list`, `init`, `enable`, `disable`, `set`, and `show-config`.
- **Manual install layout** — `hooks/` now syncs the hook bootstraps plus the embedded runtime directory instead of the old `templates/shared/` script tree.
- **Dependency handling** — Checks can now declare executables, Ruby libraries, files, and install hints, with centralized `on_missing_dependency` policy handling.

## [0.7.0] (latest)

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
