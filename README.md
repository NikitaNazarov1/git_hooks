# Git hooks usage

There was mentioned the most helpful git hooks for Rails projects.

## Add prefix with jira ticket to commit messages:
Git commit-msg hook, works with jira tickets. 
If your branch name contains a reference to jira ticket, then script automatically adds "[XXX-1234] " to commit messages, unless they mention "XXX-1234" already.

###### EXAMPLE:
Your branch name is `"task/ABC-1234/description"`.

1. `$ git commit -m 'fix bug'`
2. `$ git log`
 > [ABC-1234] Fix bug

### How to use this hook:
1. Navigate to the hooks directory
> $ cd /my-git-repo/.git/hooks
2. Create `commit-msg` file there
> $ touch commit-msg
3. Fill the created file with the following script:

You can go to the file: [commit-msg hook](https://github.com/NikitaNazarov1/git_hooks/blob/main/hooks/commit-msg). Or view the code bellow:

```ruby
#!/usr/bin/env ruby

branch_name = `git branch --no-color 2> /dev/null`[/^\* (.+)/, 1].to_s
original_commit_message = File.read(ARGV[0]).strip

pattern = /(APD-\d+)/i

if m = branch_name.match(pattern)
  jira_number = m.captures.first

  exit if original_commit_message.include?(jira_number)

  message = "[#{jira_number}] #{original_commit_message}"
  File.open(commit_message_file, 'w') {|f| f.write message }
end
```


