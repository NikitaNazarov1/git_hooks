# Rails Git Hooks

[![Gem Version](https://badge.fury.io/rb/rails_git_hooks.svg)](https://badge.fury.io/rb/rails_git_hooks)
[![Build Status](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/tests.yml?query=branch%3Amain)
[![RuboCop](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/rubocop.yml/badge.svg?branch=main)](https://github.com/NikitaNazarov1/rails_git_hooks/actions/workflows/rubocop.yml?query=branch%3Amain)

Git hooks for Rails and Ruby projects with built-in defaults, optional sparse overrides, and Overcommit-style per-check policies.

## What changed

The project now uses a **code-first hook runtime**:

- checks declare their defaults in Ruby
- hook scripts are thin bootstraps
- `.rails_git_hooks.yml` is optional and contains only overrides
- checks can be configured with `enabled`, `quiet`, `on_fail`, `on_warn`, `on_missing_dependency`, `include`, and `exclude`

## Included hooks

| Git hook | Purpose |
|---|---|
| `commit-msg` | Prefix commit messages with Jira-style ticket IDs from the current branch |
| `pre-commit` | Run commit-time checks like branch protection, debugger detection, format validation, and optional code quality checks |
| `pre-push` | Run the test suite before push |

## Quick start

### 1. Install the gem

```bash
gem install rails_git_hooks
```

Or add it to your `Gemfile`:

```ruby
gem "rails_git_hooks"
```

Then install dependencies:

```bash
bundle install
```

### 2. Install hooks

From your project root:

```bash
bundle exec rails_git_hooks install
```

This installs `commit-msg` and `pre-commit` by default.

### 3. Inspect available checks

```bash
bundle exec rails_git_hooks list
```

### 4. Override behavior only when needed

Enable RuboCop:

```bash
bundle exec rails_git_hooks enable rubocop-check
```

Make debugger statements fail instead of warn:

```bash
bundle exec rails_git_hooks set debugger-check on_fail fail
```

Disable migrations warnings:

```bash
bundle exec rails_git_hooks disable migrations-check
```

Show effective config:

```bash
bundle exec rails_git_hooks show-config
```

## Config model

You do **not** need a config file for the defaults to work.

If you want overrides, create one:

```bash
bundle exec rails_git_hooks init
```

This creates `.rails_git_hooks.yml`. The file is sparse: only your changes are stored there.

Example:

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

### Supported per-check options

| Option | Meaning |
|---|---|
| `enabled` | Enable or disable a check |
| `quiet` | Hide normal output unless the check warns or fails |
| `on_fail` | Map a check failure to `fail`, `warn`, or `pass` |
| `on_warn` | Map a warning to `warn`, `fail`, or `pass` |
| `on_missing_dependency` | Control behavior when required tools/libraries are missing |
| `include` | File paths or glob patterns that the check should apply to |
| `exclude` | File paths or glob patterns to remove from the included set |
| `command` | Override the command used by command-based checks |

## Dependency model

Checks can declare dependencies such as:

- executables like `bundle`
- Ruby libraries like `rubocop`
- required files

If a dependency is missing, the runner produces a structured result and applies the check’s `on_missing_dependency` policy. This makes missing-tool behavior consistent across all checks.

## Default checks

### `commit-msg`

- `jira-prefix`
  - enabled by default
  - prefixes commit messages with `[TICKET-123]` when the branch name contains a Jira-style ticket ID

### `pre-commit`

- `default-branch`
  - enabled by default
  - fails on `master` / `main`

- `debugger-check`
  - enabled by default
  - warns on debugger statements in Ruby, JavaScript/TypeScript, and Python

- `yaml-format-check`
  - enabled by default
  - warns on invalid `.yml` / `.yaml`

- `json-format-check`
  - enabled by default
  - warns on invalid `.json`

- `migrations-check`
  - enabled by default
  - warns when schema/data schema files appear to be missing after migrations

- `whitespace-check`
  - disabled by default
  - fails on trailing whitespace and merge conflict markers

- `rubocop-check`
  - disabled by default
  - runs RuboCop on staged Ruby files
  - default dependency behavior warns if `rubocop` is missing

### `pre-push`

- `run-tests`
  - enabled by default when `pre-push` is installed
  - runs `bundle exec rspec`

## CLI reference

| Command | Description |
|---|---|
| `rails_git_hooks install [HOOK...]` | Install hook scripts into `.git/hooks` |
| `rails_git_hooks list` | List available git hooks and check keys |
| `rails_git_hooks init` | Create `.rails_git_hooks.yml` |
| `rails_git_hooks enable CHECK_NAME` | Set `enabled: true` for a check override |
| `rails_git_hooks disable CHECK_NAME` | Set `enabled: false` for a check override |
| `rails_git_hooks set CHECK_NAME OPTION VALUE` | Set a single override option |
| `rails_git_hooks show-config` | Print effective merged configuration |

Examples:

```bash
rails_git_hooks install
rails_git_hooks install pre-push
rails_git_hooks enable rubocop-check
rails_git_hooks disable migrations-check
rails_git_hooks set debugger-check on_fail fail
rails_git_hooks set rubocop-check quiet true
rails_git_hooks show-config
```

## Manual installation

From your project (with the gem in the Gemfile or installed), run:

```bash
bundle exec rails_git_hooks install
```

This installs the thin hook bootstraps and the embedded `rails_git_hooks` runtime into `.git/hooks/`.

## Development

```bash
bundle install
bundle exec rake              # run specs
bundle exec rake build        # build the gem
bundle exec rake install      # install locally
```

## License

MIT. See [LICENSE](LICENSE).
