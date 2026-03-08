# frozen_string_literal: true

require 'fileutils'
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

desc 'Sync templates/hooks and templates/shared to hooks/ (for manual install)'
task :sync_hooks do
  hooks_dir = File.expand_path('hooks', __dir__)
  FileUtils.mkdir_p(hooks_dir)

  shared_dir = File.expand_path('templates/shared', __dir__)
  if Dir.exist?(shared_dir)
    Dir.glob(File.join(shared_dir, '**', '*')).each do |src|
      next unless File.file?(src)

      rel = src.sub(%r{\A#{Regexp.escape(shared_dir)}/}, '')
      dest = File.join(hooks_dir, rel)
      FileUtils.mkdir_p(File.dirname(dest))
      File.write(dest, File.read(src))
      puts "Synced shared/#{rel} -> hooks/"
    end
  end

  templates_dir = File.expand_path('templates/hooks', __dir__)
  Dir.each_child(templates_dir) do |name|
    next unless File.file?(File.join(templates_dir, name))

    dest = File.join(hooks_dir, name)
    File.write(dest, File.read(File.join(templates_dir, name)))
    File.chmod(0o755, dest)
    puts "Synced #{name} -> hooks/"
  end
end
