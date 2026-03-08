# frozen_string_literal: true

# Prevent commits on default branch (master/main).

branch = `git rev-parse --abbrev-ref HEAD`.strip
if %w[master main].include?(branch)
  warn "Commits on '#{branch}' are not allowed. Create a feature branch."
  exit 1
end
