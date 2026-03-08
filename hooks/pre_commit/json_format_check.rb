# frozen_string_literal: true

# Warns when staged .json files are not valid JSON (parse error). Does not block the commit.
# Runs by default with pre-commit. Expects RailsGitHooks::GIT_DIR to be set by the loader.

require 'json'

staged = `git diff --cached --name-only`.split("\n").map(&:strip).reject(&:empty?)
warnings = []

staged.each do |path|
  next unless File.file?(path)
  next unless File.extname(path) == '.json'

  content = File.read(path)
  begin
    JSON.parse(content)
  rescue JSON::ParserError => e
    warnings << "#{path}: #{e.message}"
  end
end

unless warnings.empty?
  warn ''
  warn 'Warning (JSON format check):'
  warnings.each { |e| warn "  #{e}" }
  warn ''
end
