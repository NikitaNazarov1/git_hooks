# Git Hooks

[![Gem Version](https://badge.fury.io/rb/rails_git_hooks.svg)](https://badge.fury.io/rb/rails_git_hooks)
[![Build Status](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/tests.yml?query=branch%3Amain)
[![RuboCop](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/rubocop.yml/badge.svg?branch=main)](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/rubocop.yml?query=branch%3Amain)

> Automate Jira ticket prefixes and RuboCop checks with git hooks. Built for Rails and Ruby projects.

---

## What you get

| Hook | What it does |
|------|--------------|
| **commit-msg** | Prepends `[TICKET-123]` to commit messages when your branch name contains a Jira ticket. |
| **pre-commit** | Blocks commits to `master`/`main`. Optionally runs RuboCop on staged `.rb` files (off by default). |
| **pre-push** | Runs the full test suite (`bundle exec rspec`) before push; aborts push if tests fail. |

Hooks can be disabled temporarily (e.g. for quick WIP commits or CI) without uninstalling.

---

## Quick start

**1. Install the gem**

```bash
gem install rails_git_hooks
```

Or with Bundler — add to your `Gemfile`:

```ruby
gem "rails_git_hooks"
```

Then:

```bash
bundle install
bundle exec rails_git_hooks install
```

This installs **commit-msg** (Jira ticket prefix) and **pre-commit** (blocks commits on `master`/`main` only) by default. RuboCop on staged files is off by default; enable with `rails_git_hooks enable rubocop-check`. The commit-msg hook detects any Jira-style ticket in the branch name (e.g. `APD-123`, `PROJ-456`); no project key config needed.

To also run the full test suite before push:  
`rails_git_hooks install pre-push`

> **Tip:** If the pre-commit hook doesn’t run, make it executable: `chmod +x .git/hooks/pre-commit`

---

## Commands

Run from your project root (inside a git repo).

| Command | Description |
|---------|-------------|
| `rails_git_hooks install [HOOK...]` | Install hooks. No args = install default (commit-msg + pre-commit). |
| `rails_git_hooks list` | List available hook names. |
| `rails_git_hooks disable HOOK [HOOK...] [whitespace-check] [rubocop-check]` | Disable hooks (use `*` for all) or pre-commit options. |
| `rails_git_hooks enable HOOK [HOOK...] [whitespace-check] [rubocop-check]` | Re-enable hooks or enable whitespace-check / rubocop-check. |
| `rails_git_hooks disabled` | Show which hooks are currently disabled. |

**Examples**

```bash
# Install default hooks (commit-msg + pre-commit)
rails_git_hooks install

# Install only specific hooks
rails_git_hooks install pre-commit commit-msg

# Temporarily disable pre-commit (e.g. for a quick fix)
rails_git_hooks disable pre-commit

# Disable all hooks
rails_git_hooks disable *

# Turn them back on
rails_git_hooks enable pre-commit

# Enable trailing whitespace/conflict marker check (off by default)
rails_git_hooks enable whitespace-check

# Enable RuboCop on staged .rb files (off by default)
rails_git_hooks enable rubocop-check
```

Disabled state is stored in `.git/rails_git_hooks_disabled` and persists until you run `enable`.

---

## Hooks in detail

### commit-msg — Jira ticket prefix

If your branch name contains a Jira-style ticket (e.g. `task/APD-1234/fix-bug` or `feature/PROJ-99-thing`), the hook prepends `[TICKET] ` to the commit message unless it already starts with that format. Any project key (2–5 letters + dash + digits) is detected automatically; no config needed.

**Example**

- Branch: `task/APD-1234/fix-bug`
- You run: `git commit -m 'fix bug'`
- Result: **`[APD-1234] fix bug`**

The hook skips prepending if the message already matches `[PROJECT-NUM]` at the start (e.g. `[APD-1234] fix bug`).

---

### pre-commit — Default branch protection (+ optional RuboCop)

1. **Blocks commits on `master` / `main`** — You must commit from a feature branch; direct commits to the default branch are rejected.
2. **RuboCop** (off by default) — When enabled, runs RuboCop on staged `.rb` files and aborts the commit if there are offenses. Enable with: `rails_git_hooks enable rubocop-check`. Disable with: `rails_git_hooks disable rubocop-check`. Requires the `rubocop` gem.
3. **Trailing whitespace / conflict markers** (off by default) — When enabled, rejects commits that add trailing spaces/tabs or `<<<<<<<` / `=======` / `>>>>>>>` in staged files. Enable with: `rails_git_hooks enable whitespace-check`. Disable with: `rails_git_hooks disable whitespace-check`.

If the hook doesn’t run, ensure it’s executable: `chmod +x .git/hooks/pre-commit`.

---

### pre-push — Run tests before push

Runs `bundle exec rspec` before every `git push`. If the test suite fails, the push is aborted so you don’t break CI.

Requires the `rspec` gem (or for Minitest, edit the hook to use `bundle exec rake test`). If the hook doesn’t run, ensure it’s executable: `chmod +x .git/hooks/pre-push`.

---

## Manual installation (without the gem)

If you don’t want to use the gem, copy the scripts from `hooks/` into `.git/hooks`. The project uses an overcommit-style layout: hook templates live in `templates/hooks/`; `rake sync_hooks` copies them to `hooks/` for manual install.

| File | Notes |
|------|--------|
| [commit-msg](hooks/commit-msg) | Detects any Jira-style ticket (e.g. `APD-123`) in the branch name; no config. |
| [pre-commit](hooks/pre-commit) | Requires the `rubocop` gem in the repo where you use it. |
| [pre-push](hooks/pre-push) | Runs `bundle exec rspec`; edit to use `bundle exec rake test` for Minitest. |

---

## Development

```bash
bundle install
bundle exec rake              # run specs (default task)
bundle exec rake build        # build the gem
bundle exec rake install      # install the gem locally
bundle exec rake sync_hooks   # copy templates/hooks to hooks/
```

---

## License

MIT. See [LICENSE](LICENSE).
