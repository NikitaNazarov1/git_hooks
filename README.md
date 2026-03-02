# Git Hooks

[![Gem Version](https://badge.fury.io/rb/git_hooks.svg)](https://badge.fury.io/rb/git_hooks)
[![Build Status](https://github.com/NikitaNazarov1/git_hooks/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/NikitaNazarov1/git_hooks/actions/workflows/tests.yml?query=branch%3Amain)
[![RuboCop](https://github.com/NikitaNazarov1/git_hooks/actions/workflows/rubocop.yml/badge.svg?branch=main)](https://github.com/NikitaNazarov1/git_hooks/actions/workflows/rubocop.yml?query=branch%3Amain)
[![Coverage Status](https://coveralls.io/repos/github/NikitaNazarov1/git_hooks/badge.svg?branch=main)](https://coveralls.io/github/NikitaNazarov1/git_hooks?branch=main)

> Automate Jira ticket prefixes and RuboCop checks with git hooks. Built for Rails and Ruby projects.

---

## What you get

| Hook | What it does |
|------|--------------|
| **commit-msg** | Prepends `[TICKET-123]` to commit messages when your branch name contains a Jira ticket. |
| **pre-commit** | Blocks commits to `master`/`main` and runs RuboCop on staged `.rb` files. |

Hooks can be disabled temporarily (e.g. for quick WIP commits or CI) without uninstalling.

---

## Quick start

**1. Install the gem**

```bash
gem install git_hooks
```

Or with Bundler — add to your `Gemfile`:

```ruby
gem "git_hooks"
```

Then:

```bash
bundle install
bundle exec git_hooks install
```

**2. (Optional) Set your Jira project key**

```bash
git_hooks install --jira MYPROJ
# or
export GIT_HOOKS_JIRA_PROJECT=MYPROJ
git_hooks install
```

Default is `APD` if not set.

> **Tip:** If the pre-commit hook doesn’t run, make it executable: `chmod +x .git/hooks/pre-commit`

---

## Commands

Run from your project root (inside a git repo).

| Command | Description |
|---------|-------------|
| `git_hooks install [HOOK...] [--jira PROJECT]` | Install hooks. No args = install all. |
| `git_hooks list` | List available hook names. |
| `git_hooks disable HOOK [HOOK...]` | Disable hooks (use `*` for all). |
| `git_hooks enable HOOK [HOOK...]` | Re-enable disabled hooks. |
| `git_hooks disabled` | Show which hooks are currently disabled. |

**Examples**

```bash
# Install everything with custom Jira key
git_hooks install --jira MYPROJ

# Install only specific hooks
git_hooks install pre-commit commit-msg --jira APD

# Temporarily disable pre-commit (e.g. for a quick fix)
git_hooks disable pre-commit

# Disable all hooks
git_hooks disable *

# Turn them back on
git_hooks enable pre-commit
```

Disabled state is stored in `.git/git_hooks_disabled` and persists until you run `enable`.

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

Requires the `rubocop` gem in your project. If the hook doesn’t run, ensure it’s executable: `chmod +x .git/hooks/pre-commit`.

---

## Manual installation (without the gem)

If you don’t want to use the gem, copy the scripts from `hooks/` into `.git/hooks`. The `hooks/` directory is synced from the gem templates via `rake sync_hooks` in development.

| File | Notes |
|------|--------|
| [commit-msg](hooks/commit-msg) | Replace `JIRA_PROJECT_KEY` in the script with your Jira project key (e.g. `APD`). |
| [pre-commit](hooks/pre-commit) | Requires the `rubocop` gem in the repo where you use it. |

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

---

### Badge setup

- **Gem Version** — Works after you push the gem to [RubyGems](https://rubygems.org).
- **Build Status** — Uses [GitHub Actions](.github/workflows/tests.yml); runs on push/PR to `main` or `master`.
- **Coverage** — Add the repo at [coveralls.io](https://coveralls.io), then run specs with coverage and push.
- **Maintainability** — Add the repo at [codeclimate.com](https://codeclimate.com); replace the badge above with the one they provide.
- **Inline docs** — [Inch CI](https://inch-ci.org) will pick up the repo; enable for `main` if needed.
