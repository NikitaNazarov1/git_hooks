# Git hooks usage

There were mentioned the most helpful git hooks for Rails projects.

## Add prefix with jira ticket to commit messages:
Git commit-msg hook, works with jira tickets. 
If your branch name contains a reference to jira ticket, then script automatically adds "[XXX-1234] " to commit messages, unless they mention "XXX-1234" already.

###### EXAMPLE:
Your branch name is `"task/APD-1234/description"`.

1. `$ git commit -m 'fix bug'`
2. `$ git log`
 > [APD-1234] Fix bug

### How to use this hook:
1. Navigate to the hooks directory
> $ cd /my-git-repo/.git/hooks
2. Create `commit-msg` file there if it's absent
> $ touch commit-msg
3. Fill the created file with the following script:

You can go to the file: [commit-msg hook](https://github.com/NikitaNazarov1/git_hooks/blob/main/hooks/commit-msg). Or view the code bellow:

```ruby
#!/usr/bin/env ruby

branch_name = `git branch --no-color 2> /dev/null`[/^\* (.+)/, 1].to_s
original_commit_message = File.read(ARGV[0]).strip

pattern = /(APD-\d+)/i # APD - jira project name, please replace it by yours

if m = branch_name.match(pattern)
  jira_number = m.captures.first

  exit if original_commit_message.include?(jira_number)

  message = "[#{jira_number}] #{original_commit_message}"
  File.open(commit_message_file, 'w') {|f| f.write message }
end
```

### Note that you need to replace your jira project key in the script!

## Run rubocop on changed files before commiting:
This script runs rubocop on changed files after `git commit` command. If there is any linter errors, commit rollbacks.

###### EXAMPLE:

1. `$ git commit -m 'fix bug'`
> Inspecting 1 file  
> W
> 
> Offenses: W: Lint/DuplicateHashKey:

2. `$ git log`
> [JIRA-123] previous commit

### How to use this hook:
1. Navigate to the hooks directory
> $ cd /my-git-repo/.git/hooks
2. Create `pre-commit` file there if it's absent
> $ touch pre-commit
3. Fill the created file with the following script:

You can go to the file: [pre-commit hook](https://github.com/NikitaNazarov1/git_hooks/blob/main/hooks/pre-commit). Or view the code bellow:

```ruby
#!/usr/bin/env ruby

require 'english'
require 'rubocop'

ADDED_OR_MODIFIED = /A|AM|^M/.freeze

changed_files = `git status --porcelain`.split(/\n/).
    select { |file_name_with_status|
      file_name_with_status =~ ADDED_OR_MODIFIED
    }.
    map { |file_name_with_status|
      file_name_with_status.split(' ')[1]
    }.
    select { |file_name|
      File.extname(file_name) == '.rb'
    }.join(' ')

system("rubocop #{changed_files}") unless changed_files.empty?

exit $CHILD_STATUS.to_s[-1].to_i
```

### Note that pre-commit hook disabled by default, to enable this hook you need to run `chmod +x .git/hooks/pre-commit` in your repo!
