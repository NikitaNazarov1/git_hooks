# frozen_string_literal: true

# Prevent commits on default branch (master/main).

branch = `git rev-parse --abbrev-ref HEAD`.strip
if %w[master main].include?(branch)
  warn ''
  warn "Commits on '#{branch}' are not allowed. Create a feature branch."
  warn ''
  exit 1
end
