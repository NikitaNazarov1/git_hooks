# Rails Git Hooks

[![Gem Version](https://badge.fury.io/rb/rails_git_hooks.svg)](https://badge.fury.io/rb/rails_git_hooks)
[![Build Status](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/tests.yml?query=branch%3Amain)
[![RuboCop](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/rubocop.yml/badge.svg?branch=main)](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/rubocop.yml?query=branch%3Amain)

Git hooks for Rails and Ruby projects: sensible defaults out of the box, optional YAML overrides, and per-check policies (enable/disable, fail vs warn, include/exclude).

## Features

- **Code-first runtime** — Checks are Ruby classes; hook scripts are thin bootstraps that delegate to a shared runtime.
- **Sparse config** — Defaults live in the gem ([config/defaults.yml](https://github.com/NikitaNazarov1/rails_git_hooks/blob/main/lib/rails_git_hooks/config/defaults.yml)). But you can redefine them via your own yml config file in a root repository.
- **Flexible configuration options** — Per check: `enabled`, `quiet`, `on_fail`, `on_warn`, `on_missing_dependency`, `include`, `exclude`, `command`.
- **Dependency handling** — Checks declare executables/libraries; missing deps are handled by a single policy (`on_missing_dependency`).

## Included hooks and checks

### When hooks trigger

| Hook | Triggers at |
|------|-------------|
| **commit-msg** | After the user finishes editing the commit message, before the commit is created. |
| **pre-commit** | Before the commit is created (when running `git commit`). |
| **pre-push** | Before pushing to the remote (when running `git push`). |
| **post-checkout** | After switching branches or restoring files (e.g. `git checkout`). |
| **post-merge** | After a merge completes (when running `git merge`). |

### Checks by hook

| Hook         | Check key            | Enabled By Default | Description |
|-------------|----------------------|---------|-------------|
| **commit-msg** | `jira-prefix`        | ✅      | Prefix commit messages with Jira-style ticket IDs from the branch name (e.g. `[TICKET-123]`). |
| **commit-msg** | `not-empty`          | ✅      | Reject empty commit messages. |
| **pre-commit** | `default-branch`     | ✅      | Block commits on `master` / `main`, prompt to use a feature branch. |
| **pre-commit** | `debugger-check`     | ✅      | Warn (or fail) on debugger statements in Ruby, JavaScript/TypeScript, and Python. |
| **pre-commit** | `yaml-format-check`  | ✅      | Warn on invalid `.yml` / `.yaml` files. |
| **pre-commit** | `json-format-check`  | ✅      | Warn on invalid `.json` files. |
| **pre-commit** | `migrations-check`   | ✅      | Warn when migration files are staged but schema/data_schema files are not. |
| **pre-commit** | `whitespace-check`   | Off     | Fail on trailing whitespace and merge conflict markers. |
| **pre-commit** | `rubocop-check`      | Off     | Run RuboCop on staged Ruby files (requires `rubocop` in the project). |
| **pre-commit** | `rails-best-practices` | Off   | Warn on Rails best practices violations (requires `rails_best_practices` gem). |
| **pre-commit** | `erblint-check`       | Off   | Run `erblint` on staged ERB files (requires `erblint` gem). |
| **pre-commit** | `eslint-check`        | Off   | Run `eslint` on staged JavaScript files (.js, .jsx, .mjs, .cjs). You can set `command` in config to use an npm script (e.g. `npm run lint`). |
| **pre-commit** | `golint-check`        | Off   | Run `golint` on staged Go files (requires `golint`). |
| **pre-commit** | `haml-lint-check`     | Off   | Run `haml-lint` on staged HAML files (requires `haml_lint` gem). |
| **pre-commit** | `jslint-check`        | Off   | Run `jslint` on staged JavaScript files (.js, .jsx, .mjs, .cjs). |
| **pre-commit** | `php-lint-check`      | Off   | Run `php -l` (syntax check) on staged PHP files. |
| **pre-commit** | `pylint-check`        | Off   | Run `pylint` on staged Python files. |
| **pre-commit** | `scss-lint-check`     | Off   | Run `scss-lint` on staged SCSS files (requires `scss_lint` gem). |
| **pre-commit** | `go-vet-check`        | Off   | Run `go vet` on staged Go files. |
| **pre-push**   | `run-tests`          | Off     | Run test suite before push (default: `bundle exec rspec`). Enable in config to install pre-push. |
| **pre-push**   | `run-pytest`         | Off     | Run pytest test suite before push. Enable in config to install pre-push. |
| **pre-push**   | `run-go-test`        | Off     | Run `go test` suite before push. Enable in config to install pre-push. |
| **post-checkout** | `bundle-install`   | Off     | Run `bundle install` when Gemfile or Gemfile.lock changed after a branch checkout. |
| **post-checkout** | `db-migrate`       | Off     | Run `rails db:migrate` when migrations or schema changed after a branch checkout. |
| **post-checkout** | `npm-install`      | Off     | Run `npm install` when package.json or package-lock.json changed after a branch checkout. |
| **post-checkout** | `yarn-install`     | Off     | Run `yarn install` when package.json or yarn.lock changed after a branch checkout. |
| **post-merge** | `bundle-install`     | Off     | Run `bundle install` when Gemfile or Gemfile.lock changed after a merge. |
| **post-merge** | `db-migrate`        | Off     | Run `rails db:migrate` when migrations or schema changed after a merge. |
| **post-merge** | `npm-install`       | Off     | Run `npm install` when package.json or package-lock.json changed after a merge. |
| **post-merge** | `yarn-install`      | Off     | Run `yarn install` when package.json or yarn.lock changed after a merge. |

## Quick start

### 1. Add the gem

**Gemfile:**

```ruby
gem "rails_git_hooks"
```

Then:

```bash
bundle install
```

Or install globally: `gem install rails_git_hooks`.

### 2. Install hooks

From your project root:

```bash
bundle exec rails_git_hooks install
```

With default config this installs **commit-msg**, **pre-commit**, **post-checkout**, and **post-merge** into `.git/hooks/` and copies the runtime there (pre-push is off by default; enable `run-tests` in config to add it).

## Configuration

### Priority (low → high)

1. **Built-in defaults** (in the gem’s `config/defaults.yml`)
2. **`.rails_git_hooks.yml`** in the repo root (sparse overrides; commit this)
3. **`.rails_git_hooks.local.yml`** in the repo root (optional; overrides the above, typically gitignored)

**Create the main override file:**

```bash
bundle exec rails_git_hooks init
```

**Optional:** Create `.rails_git_hooks.local.yml` in the repo root for personal overrides (merged on top of `.rails_git_hooks.yml`). Add it to `.gitignore` if you don’t want to commit it.

### Example override file

```yaml
PreCommit:
  DebuggerCheck:
    on_fail: fail

  RuboCop:
    enabled: true
    quiet: true
    include:
      - "app/**/*.rb"
      - "lib/**/*.rb"
    exclude:
      - "db/schema.rb"

  # Run eslint via your npm script (useful if the script has its own config):
  Eslint:
    enabled: true
    command: [npm, run, lint]
```

### Per-check options

| Option | Description |
|--------|--------------|
| `enabled` | Turn the check on or off. |
| `quiet` | Suppress normal output unless the check warns or fails. |
| `on_fail` | `fail`, `warn`, or `pass` when the check fails. |
| `on_warn` | `warn`, `fail`, or `pass` when the check would warn. |
| `on_missing_dependency` | Behavior when a required executable/library is missing. |
| `include` | Glob patterns for files the check applies to. |
| `exclude` | Glob patterns to exclude from `include`. |
| `command` | Override the command for checks that run external commands. |

## Contributing

Contributions are welcome. Open an [issue](https://github.com/NikitaNazarov1/rails_git_hooks/issues) for bugs or ideas, or submit a pull request.

## License

MIT. See [LICENSE](LICENSE).
