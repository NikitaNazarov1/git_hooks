# Git Hooks

Git hooks for Rails projects: Auto Jira ticket prefix in commit messages and RuboCop on staged files.

## Installation (as a gem)

```bash
gem install git_hooks
```

Or add to your Gemfile:

```ruby
gem "git_hooks"
```

Then run:

```bash
bundle exec git_hooks install
```

### Note that pre-commit hook disabled by default, to enable this hook you need to run `chmod +x .git/hooks/pre-commit` in your repo!

### Install hooks in your repo

From your project root (must be inside a git repo):

```bash
# Install all hooks (commit-msg + pre-commit)
git_hooks install

# Install with a custom Jira project key (default is APD)
git_hooks install --jira MYPROJ

# Install only specific hooks
git_hooks install commit-msg
git_hooks install pre-commit commit-msg --jira JIRA
```

You can also set the Jira project key via environment variable:

```bash
export GIT_HOOKS_JIRA_PROJECT=MYPROJ
git_hooks install
```

List available hooks:

```bash
git_hooks list
```

### Disable and enable hooks

Hooks stay installed but skip running when disabled (useful for quick commits or CI):

```bash
# Disable one or more hooks
git_hooks disable pre-commit
git_hooks disable commit-msg pre-commit

# Disable all hooks
git_hooks disable *

# Re-enable hooks
git_hooks enable pre-commit
git_hooks enable commit-msg pre-commit

# See which hooks are disabled
git_hooks disabled
```

Disabled state is stored in `.git/git_hooks_disabled`.

---

## Hooks

### commit-msg — Jira ticket prefix

If your branch name contains a Jira ticket (e.g. `task/APD-1234/description`), the hook adds `[APD-1234] ` to the commit message unless it’s already there.

**Example**

- Branch: `task/APD-1234/fix-bug`
- `git commit -m 'fix bug'`
- Result: `[APD-1234] fix bug`

Configure the Jira project key when installing (e.g. `--jira APD` or `GIT_HOOKS_JIRA_PROJECT=APD`).

### pre-commit — Protect default branch + RuboCop

1. **Blocks commits on `master` / `main`** — You must commit from a feature branch; direct commits to the default branch are rejected.
2. **Runs RuboCop** on staged `.rb` files. If there are offenses, the commit is aborted.

**Note:** The pre-commit hook is installed executable. If it doesn’t run, ensure it’s executable: `chmod +x .git/hooks/pre-commit`.

---

## Manual installation (without the gem)

See the hook source and copy the scripts into `.git/hooks`:

- [commit-msg](hooks/commit-msg) — replace the Jira project key in the script (e.g. `APD`) with yours.
- [pre-commit](hooks/pre-commit) — requires `rubocop` gem.

---

## Development

```bash
bundle install
bundle exec rake build   # build the gem
bundle exec rake install # install the gem locally
```

## License

MIT. See [LICENSE](LICENSE).
