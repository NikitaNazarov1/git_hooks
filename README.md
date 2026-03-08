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
| **pre-commit** | Blocks commits to `master`/`main` and runs RuboCop on staged `.rb` files. |
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

This installs **commit-msg** (Jira ticket prefix) and **pre-commit** (blocks commits on `master`/`main` + RuboCop on staged `.rb` files) by default.

**2. Set your Jira project key**

Replace the default by passing your project key at install time or via env:

```bash
rails_git_hooks install --jira MYPROJ
# or
export GIT_HOOKS_JIRA_PROJECT=MYPROJ
rails_git_hooks install
```

Default is `APD` if not set. For manual install: replace `JIRA_PROJECT_KEY` in the commit-msg script with your key (e.g. `APD`).

To also run the full test suite before push:  
`rails_git_hooks install pre-push`

> **Tip:** If the pre-commit hook doesn’t run, make it executable: `chmod +x .git/hooks/pre-commit`

---

## Commands

Run from your project root (inside a git repo).

| Command | Description |
|---------|-------------|
| `rails_git_hooks install [HOOK...] [--jira PROJECT]` | Install hooks. No args = install default (commit-msg + pre-commit). |
| `rails_git_hooks list` | List available hook names. |
| `rails_git_hooks disable HOOK [HOOK...] [whitespace-check]` | Disable hooks (use `*` for all) or the whitespace-check. |
| `rails_git_hooks enable HOOK [HOOK...] [whitespace-check]` | Re-enable hooks or enable whitespace-check. |
| `rails_git_hooks disabled` | Show which hooks are currently disabled. |

**Examples**

```bash
# Install everything with custom Jira key
rails_git_hooks install --jira MYPROJ

# Install only specific hooks
rails_git_hooks install pre-commit commit-msg --jira APD

# Temporarily disable pre-commit (e.g. for a quick fix)
rails_git_hooks disable pre-commit

# Disable all hooks
rails_git_hooks disable *

# Turn them back on
rails_git_hooks enable pre-commit

# Enable rejection of trailing whitespace and conflict markers in staged files (off by default)
rails_git_hooks enable whitespace-check
```

Disabled state is stored in `.git/rails_git_hooks_disabled` and persists until you run `enable`.

---

## Hooks in detail

### commit-msg — Jira ticket prefix

If your branch name contains a Jira ticket (e.g. `task/APD-1234/fix-bug`), the hook prepends `[APD-1234] ` to the commit message unless it’s already there.

**Example**

- Branch: `task/APD-1234/fix-bug`
- You run: `git commit -m 'fix bug'`
- Result: **`[APD-1234] fix bug`**

Set the Jira project key at install time with `--jira PROJECT` or `GIT_HOOKS_JIRA_PROJECT`.

---

### pre-commit — Default branch protection + RuboCop

1. **Blocks commits on `master` / `main`** — You must commit from a feature branch; direct commits to the default branch are rejected.
2. **Runs RuboCop** on staged `.rb` files. If there are offenses, the commit is aborted.
3. **Trailing whitespace / conflict markers** (off by default) — When enabled, rejects commits that add trailing spaces/tabs or `<<<<<<<` / `=======` / `>>>>>>>` in staged files. Enable with: `rails_git_hooks enable whitespace-check`. Disable with: `rails_git_hooks disable whitespace-check`.

Requires the `rubocop` gem in your project. If the hook doesn’t run, ensure it’s executable: `chmod +x .git/hooks/pre-commit`.

---

### pre-push — Run tests before push

Runs `bundle exec rspec` before every `git push`. If the test suite fails, the push is aborted so you don’t break CI.

Requires the `rspec` gem (or for Minitest, edit the hook to use `bundle exec rake test`). If the hook doesn’t run, ensure it’s executable: `chmod +x .git/hooks/pre-push`.

---

## Manual installation (without the gem)

If you don’t want to use the gem, copy the scripts from `hooks/` into `.git/hooks`. The `hooks/` directory is synced from the gem templates via `rake sync_hooks` in development.

| File | Notes |
|------|--------|
| [commit-msg](hooks/commit-msg) | Replace `JIRA_PROJECT_KEY` in the script with your Jira project key (e.g. `APD`). |
| [pre-commit](hooks/pre-commit) | Requires the `rubocop` gem in the repo where you use it. |
| [pre-push](hooks/pre-push) | Runs `bundle exec rspec`; edit to use `bundle exec rake test` for Minitest. |

---

## Development

```bash
bundle install
bundle exec rake              # run specs (default task)
bundle exec rake build        # build the gem
bundle exec rake install      # install the gem locally
bundle exec rake sync_hooks   # copy templates to hooks/
```

---

## License

MIT. See [LICENSE](LICENSE).
