# frozen_string_literal: true

# Prepends [TICKET] to commit message when branch name contains a Jira-style ticket.
# No config needed; works with any project key (2–5 letters + digits).

commit_message_file = ARGV[0]
branch_name = `git branch --no-color 2> /dev/null`[/^\* (.+)/, 1].to_s
original_commit_message = File.read(commit_message_file).strip

branch_ticket_pattern = /([A-Z]{2,5}-\d+)/i
skip_if_already_prefixed = /\A\[[A-Z]{2,5}-\d+\]/i

if (m = branch_name.match(branch_ticket_pattern))
  jira_ticket = m.captures.first

  unless original_commit_message.match?(skip_if_already_prefixed) || original_commit_message.include?(jira_ticket)
    message = "[#{jira_ticket}] #{original_commit_message}"
    File.open(commit_message_file, 'w') { |f| f.write message }
  end
end
