# frozen_string_literal: true

# Trailing whitespace / conflict markers (off by default; enable with rails_git_hooks enable whitespace-check).
# Expects RailsGitHooks::GIT_DIR to be set by the loader.

git_dir = RailsGitHooks::GIT_DIR
whitespace_check_file = File.join(git_dir, 'rails_git_hooks_whitespace_check')
if File.exist?(whitespace_check_file)
  staged = `git diff --cached --name-only`.split("\n").map(&:strip).reject(&:empty?)
  errors = []
  staged.each do |path|
    next unless File.file?(path)

    File.read(path).lines.each_with_index do |line, i|
      errors << "#{path}:#{i + 1}: trailing whitespace" if line.match?(/[ \t]\z/)
      stripped = line.strip
      errors << "#{path}:#{i + 1}: conflict marker" if stripped.start_with?('<<<<<<<', '=======', '>>>>>>>')
    end
  end
  unless errors.empty?
    warn ''
    warn 'Commit rejected (whitespace/conflict check):'
    errors.uniq.each { |e| warn "  #{e}" }
    warn ''
    exit 1
  end
end
