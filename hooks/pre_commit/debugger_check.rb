# frozen_string_literal: true

# Warns when staged files contain debugger statements (Ruby, JavaScript/TypeScript, Python).
# Does not block the commit. Expects RailsGitHooks::GIT_DIR to be set by the loader.

# [ extension => [ [ regex, label ], ... ] ]
DEBUGGER_PATTERNS = {
  '.rb' => [
    [/\bbinding\.pry\b/, 'binding.pry'],
    [/\bbinding\.irb\b/, 'binding.irb'],
    [/\bdebugger\b/, 'debugger'],
    [/\bbyebug\b/, 'byebug']
  ],
  '.js' => [[/\bdebugger\s*;?/, 'debugger']],
  '.jsx' => [[/\bdebugger\s*;?/, 'debugger']],
  '.ts' => [[/\bdebugger\s*;?/, 'debugger']],
  '.tsx' => [[/\bdebugger\s*;?/, 'debugger']],
  '.mjs' => [[/\bdebugger\s*;?/, 'debugger']],
  '.cjs' => [[/\bdebugger\s*;?/, 'debugger']],
  '.py' => [
    [/\bbreakpoint\s*\(\s*\)/, 'breakpoint()'],
    [/\bpdb\.set_trace\s*\(\s*\)/, 'pdb.set_trace()'],
    [/\bipdb\.set_trace\s*\(\s*\)/, 'ipdb.set_trace()']
  ]
}.freeze

staged = `git diff --cached --name-only`.split("\n").map(&:strip).reject(&:empty?)
warnings = []

staged.each do |path|
  next unless File.file?(path)

  ext = File.extname(path)
  patterns = DEBUGGER_PATTERNS[ext]
  next unless patterns

  File.read(path).lines.each_with_index do |line, i|
    patterns.each do |regex, label|
      warnings << "#{path}:#{i + 1}: #{label}" if line.match?(regex)
    end
  end
end

unless warnings.empty?
  warn 'Warning (debugger check):'
  warnings.uniq.each { |e| warn "  #{e}" }
end
# Does not exit 1 — commit is never blocked by this check
