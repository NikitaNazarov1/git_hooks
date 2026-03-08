# Rails Git Hooks

[![Gem Version](https://badge.fury.io/rb/rails_git_hooks.svg)](https://badge.fury.io/rb/rails_git_hooks)
[![Build Status](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/tests.yml?query=branch%3Amain)
[![RuboCop](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/rubocop.yml/badge.svg?branch=main)](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/rubocop.yml?query=branch%3Amain)

Most useful git hooks for Rails and Ruby. Install only what you need. Turn hooks off anytime without uninstalling.

---

## What’s included

| Hook | Description |
|------|-------------|
| **commit-msg** | Adds `[TICKET-123]` to commit messages when your branch name contains a Jira ticket. |
| **pre-commit** | Blocks commits to `master`/`main`. Warns about debugger statements and invalid staged YAML (`.yml`/`.yaml`) and JSON (`.json`). Optional: RuboCop, trailing-whitespace/conflict checks. |
| **pre-push** | Runs `bundle exec rspec` before push and blocks push if tests fail. |

- **Installed by default:** `commit-msg` and `pre-commit` (branch protection + debugger, YAML/JSON format warnings + migrations check; RuboCop and whitespace checks are off).
- **Optional:** `pre-push`, RuboCop, and whitespace/conflict checks — enable when you want them. Migrations check is on by default; disable with `rails_git_hooks disable migrations-check` if needed.

---

## Quick start

### 1. Install the gem

**Standalone:**

```bash
gem install rails_git_hooks
```

**With Bundler** — add to your `Gemfile`:

```ruby
gem "rails_git_hooks"
```

Then:

```bash
bundle install
```

### 2. Install hooks

From your project root (inside the git repo):

```bash
bundle exec rails_git_hooks install
```

This installs **commit-msg** and **pre-commit** (default-branch protection only). No Jira project key needed — the hook detects ticket IDs like `APD-123` or `PROJ-456` from the branch name.

### 3. Optional: add more

```bash
# Run tests before every push
rails_git_hooks install pre-push

# Run RuboCop on staged .rb files before commit
rails_git_hooks enable rubocop-check

# Reject trailing whitespace and conflict markers in staged files
rails_git_hooks enable whitespace-check

# Migrations check is on by default; disable with: rails_git_hooks disable migrations-check
```

**Tip:** If a hook doesn’t run, make it executable: `chmod +x .git/hooks/<hook-name>`

---

## Command reference

All commands are run from the project root.

| Command | Description |
|---------|-------------|
| `rails_git_hooks install [HOOK...]` | Install hooks. No arguments = install default (commit-msg + pre-commit). |
| `rails_git_hooks list` | List available hook names. |
| `rails_git_hooks disable HOOK [...]` | Disable hooks or options (use `*` for all). |
| `rails_git_hooks enable HOOK [...]` | Re-enable hooks or enable optional checks. |
| `rails_git_hooks disabled` | Show currently disabled hooks. |

**Common examples:**

```bash
rails_git_hooks install                    # default hooks
rails_git_hooks install pre-push          # add pre-push
rails_git_hooks disable pre-commit        # turn off pre-commit temporarily
rails_git_hooks disable *                 # turn off all
rails_git_hooks enable pre-commit         # turn pre-commit back on
rails_git_hooks enable rubocop-check      # run RuboCop on staged .rb files
rails_git_hooks enable whitespace-check   # reject trailing ws & conflict markers
rails_git_hooks disable migrations-check # turn off migrations check (on by default)
```

Disabled state is stored in `.git/rails_git_hooks_disabled` and persists until you run `enable`.

---

## Hooks in detail

### commit-msg — Jira ticket prefix

**What it does:** If the branch name contains a Jira-style ticket (e.g. `task/APD-1234/fix-bug`), the hook prepends `[APD-1234]` to the commit message — unless the message already starts with that format. Works with any project key (2–5 letters + digits); no config.

**Example:**

- Branch: `task/APD-1234/fix-bug`
- Command: `git commit -m 'fix bug'`
- Result: **`[APD-1234] fix bug`**

---

### pre-commit — Branch protection and optional checks

**Always on (when installed):**

- Blocks commits to `master` or `main`. You must commit from a feature branch.
- **Debugger check** — Warns (does not block) when staged files contain debugger statements: Ruby (`binding.pry`, `debugger`, `byebug`, `binding.irb`), JavaScript/TypeScript (`.js`, `.jsx`, `.ts`, `.tsx` — `debugger`), Python (`breakpoint()`, `pdb.set_trace()`, `ipdb.set_trace()`).
- **YAML format check** — Warns (does not block) when any staged `.yml` or `.yaml` file is not valid YAML (parse error). Reports file and line from the parser.
- **JSON format check** — Warns (does not block) when any staged `.json` file is not valid JSON (parse error). Reports file and parser message.

**Optional (off by default):**

1. **RuboCop** — Run RuboCop on staged `.rb` files; commit fails if there are offenses.  
   `rails_git_hooks enable rubocop-check` / `disable rubocop-check`. Requires the `rubocop` gem.

2. **Whitespace & conflict markers** — Reject commits that add trailing spaces/tabs or `<<<<<<<` / `=======` / `>>>>>>>` in staged files.  
   `rails_git_hooks enable whitespace-check` / `disable whitespace-check`.

3. **Migrations check** — Warns (does not block) when: (a) migration file(s) are staged but neither `db/schema.rb` nor `db/structure.sql` is staged; (b) data migration file(s) in `db/data/` or `db/data_migrate/` are staged but `db/data_schema.rb` is not. **On by default.** Disable with `rails_git_hooks disable migrations-check`.

---

### pre-push — Run tests before push

Runs `bundle exec rspec` before every `git push`. If the suite fails, the push is aborted. Not installed by default; add with `rails_git_hooks install pre-push`. For Minitest, edit the hook to use `bundle exec rake test`.

---

## Manual installation (without the gem)

Copy the **entire** `hooks/` directory into your repo’s `.git/hooks/` (so the hook scripts and the `pre_commit/`, `commit_msg/`, `pre_push/` subdirs are all under `.git/hooks/`). Run `rake sync_hooks` to regenerate `hooks/` from `templates/hooks/` and `templates/shared/`.

| Script | Notes |
|--------|--------|
| [commit-msg](hooks/commit-msg) | Jira-style ticket prefix; no config. |
| [pre-commit](hooks/pre-commit) | Branch protection + debugger, YAML and JSON format warnings; optional RuboCop (requires `rubocop` gem). |
| [pre-push](hooks/pre-push) | Runs `bundle exec rspec`; edit for Minitest if needed. |

---

## Development

```bash
bundle install
bundle exec rake              # run specs
bundle exec rake build        # build the gem
bundle exec rake install      # install locally
bundle exec rake sync_hooks   # copy templates (hooks + shared subdirs) → hooks/
```

---

## License

MIT. See [LICENSE](LICENSE).
