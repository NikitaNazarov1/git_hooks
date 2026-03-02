# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.4.1] - (latest)

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
