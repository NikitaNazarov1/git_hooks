# frozen_string_literal: true

# RuboCop on staged .rb files (off by default; enable with rails_git_hooks enable rubocop-check).
# Expects RailsGitHooks::GIT_DIR to be set by the loader.

git_dir = RailsGitHooks::GIT_DIR
rubocop_check_file = File.join(git_dir, 'rails_git_hooks_rubocop')
if File.exist?(rubocop_check_file)
  require 'english'
  require 'rubocop'

  ADDED_OR_MODIFIED = /A|AM|^M/.freeze

  changed_files = `git status --porcelain`.split(/\n/)
                                          .select { |file_name_with_status| file_name_with_status =~ ADDED_OR_MODIFIED }
                                          .map { |file_name_with_status| file_name_with_status.split(' ')[1] }
                                          .select { |file_name| File.extname(file_name) == '.rb' }
                                          .join(' ')

  unless changed_files.empty?
    system("rubocop #{changed_files}")
    exit $CHILD_STATUS.to_s[-1].to_i
  end
end
