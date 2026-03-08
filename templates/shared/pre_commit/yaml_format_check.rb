# frozen_string_literal: true

# Warns when staged .yml/.yaml files are not valid YAML (parse error). Does not block the commit.
# Runs by default with pre-commit. Expects RailsGitHooks::GIT_DIR to be set by the loader.

require 'yaml'

YAML_EXTS = %w[.yml .yaml].freeze

staged = `git diff --cached --name-only`.split("\n").map(&:strip).reject(&:empty?)
warnings = []

staged.each do |path|
  next unless File.file?(path)
  next unless YAML_EXTS.include?(File.extname(path))

  content = File.read(path)
  begin
    YAML.load(content) # rubocop:disable Security/YAMLLoad
  rescue Psych::SyntaxError => e
    loc = e.line ? "#{path}:#{e.line}" : path
    warnings << "#{loc}: #{e.message}"
  end
end

unless warnings.empty?
  warn ''
  warn 'Warning (YAML format check):'
  warnings.each { |e| warn "  #{e}" }
  warn ''
end
