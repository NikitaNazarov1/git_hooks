# frozen_string_literal: true

require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
  # RSpec not available
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  # RuboCop not available
end

desc 'Sync hook templates from lib/git_hooks/templates to hooks/ (for manual install)'
task :sync_hooks do
  templates_dir = File.expand_path('lib/git_hooks/templates', __dir__)
  hooks_dir = File.expand_path('hooks', __dir__)
  Dir.each_child(templates_dir) do |name|
    next unless File.file?(File.join(templates_dir, name))

    src = File.join(templates_dir, name)
    dest = File.join(hooks_dir, name)
    File.write(dest, File.read(src))
    File.chmod(0o755, dest)
    puts "Synced #{name} -> hooks/"
  end
end
