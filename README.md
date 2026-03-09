# Rails Git Hooks

[![Gem Version](https://badge.fury.io/rb/rails_git_hooks.svg)](https://badge.fury.io/rb/rails_git_hooks)
[![Build Status](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/tests.yml?query=branch%3Amain)
[![RuboCop](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/rubocop.yml/badge.svg?branch=main)](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/rubocop.yml?query=branch%3Amain)

Git hooks for Rails and Ruby projects: sensible defaults out of the box, optional YAML overrides, and per-check policies (enable/disable, fail vs warn, include/exclude).

## Features

- **Code-first runtime** — Checks are Ruby classes; hook scripts are thin bootstraps that delegate to a shared runtime.
- **Sparse config** — Defaults live in the gem ([`config/defaults.yml`](https://github.com/NikitaNazarov1/rails_git_hooks/blob/main/lib/rails_git_hooks/config/defaults.yml)); you only add overrides in `.rails_git_hooks.yml` (and optionally `.rails_git_hooks.local.yml` for personal tweaks).
- **Flexible configuration options** — Per check: `enabled`, `quiet`, `on_fail`, `on_warn`, `on_missing_dependency`, `include`, `exclude`, `command`.
- **Dependency handling** — Checks declare executables/libraries; missing deps are handled by a single policy (`on_missing_dependency`).

## Included hooks and checks

| Hook         | Check key            | Enabled By Default | Description |
|-------------|----------------------|---------|-------------|
| **commit-msg** | `jira-prefix`        | ✅      | Prefix commit messages with Jira-style ticket IDs from the branch name (e.g. `[TICKET-123]`). |
| **pre-commit** | `default-branch`     | ✅      | Block commits on `master` / `main`; prompt to use a feature branch. |
| **pre-commit** | `debugger-check`     | ✅      | Warn (or fail) on debugger statements in Ruby, JavaScript/TypeScript, and Python. |
| **pre-commit** | `yaml-format-check`  | ✅      | Warn on invalid `.yml` / `.yaml` files. |
| **pre-commit** | `json-format-check`  | ✅      | Warn on invalid `.json` files. |
| **pre-commit** | `migrations-check`   | ✅      | Warn when migration files are staged but schema/data_schema files are not. |
| **pre-commit** | `whitespace-check`   | Off     | Fail on trailing whitespace and merge conflict markers. |
| **pre-commit** | `rubocop-check`      | Off     | Run RuboCop on staged Ruby files (requires `rubocop` in the project). |
| **pre-push**   | `run-tests`          | Off     | Run test suite before push (default: `bundle exec rspec`). Enable in config to install pre-push. |

`install` installs every hook that has at least one **enabled** check in the merged config (defaults + `.rails_git_hooks.yml` + `.rails_git_hooks.local.yml`). With no config file, only **commit-msg** and **pre-commit** are installed (run-tests is off by default). Enable checks in `.rails_git_hooks.yml` (e.g. pre-push’s `run-tests`) and run `install` again to add more hooks.

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

With default config this installs **commit-msg** and **pre-commit** into `.git/hooks/` and copies the runtime there (pre-push is off by default; enable `run-tests` in config to add it).

### 3. Override defaults (optional)

No config file is required; defaults work as-is. To change behavior, edit `.rails_git_hooks.yml` (create it with `bundle exec rails_git_hooks init` if needed). Same structure as the example under [Configuration](#configuration).

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

## CLI reference

| Command | Description |
|---------|--------------|
| `rails_git_hooks install` | Install hooks that have at least one enabled check in the merged config (defaults + .rails_git_hooks.yml + .rails_git_hooks.local.yml). |
| `rails_git_hooks init` | Create an empty `.rails_git_hooks.yml`. |

## Contributing

Contributions are welcome. Open an [issue](https://github.com/NikitaNazarov1/rails_git_hooks/issues) for bugs or ideas, or submit a pull request.

## License

MIT. See [LICENSE](LICENSE).
