# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'tmpdir'

RSpec.describe GitHooks::Installer do
  around do |example|
    project_root = File.expand_path('../..', __dir__)
    Dir.mktmpdir('rails_git_hooks_spec', project_root) do |tmpdir|
      @tmpdir = tmpdir
      # Use a fake "git" dir (no .git in path to avoid sandbox restrictions)
      @git_dir = File.join(tmpdir, 'repo_git')
      @hooks_dir = File.join(@git_dir, 'hooks')
      FileUtils.mkdir_p(@hooks_dir)
      example.run
    end
  end

  let(:installer) { described_class.new(git_dir: @git_dir) }

  describe '.available_hook_names' do
    it 'returns hook names from templates directory (no git repo required)' do
      expect(described_class.available_hook_names).to contain_exactly('commit-msg', 'pre-commit', 'pre-push')
    end
  end

  describe '#available_hooks' do
    it 'returns same as .available_hook_names' do
      expect(installer.available_hooks).to eq(described_class.available_hook_names)
    end
  end

  describe '#install' do
    it 'installs default hooks (commit-msg + pre-commit) when no names given' do
      installed = installer.install
      expect(installed).to contain_exactly('commit-msg', 'pre-commit')
      expect(File).to be_executable(File.join(@hooks_dir, 'commit-msg'))
      expect(File).to be_executable(File.join(@hooks_dir, 'pre-commit'))
      expect(File).not_to exist(File.join(@hooks_dir, 'pre-push'))
    end

    it 'installs only requested hooks' do
      installed = installer.install('pre-commit')
      expect(installed).to eq(['pre-commit'])
      expect(File).to exist(File.join(@hooks_dir, 'pre-commit'))
      expect(File).not_to exist(File.join(@hooks_dir, 'commit-msg'))
    end

    it 'installs commit-msg and shared Jira-prefix logic in commit_msg/ subdir' do
      installer.install('commit-msg')
      commit_msg_content = File.read(File.join(@hooks_dir, 'commit-msg'))
      expect(commit_msg_content).to include("'commit_msg', 'jira_prefix.rb'")
      jira_logic = File.read(File.join(@hooks_dir, 'commit_msg', 'jira_prefix.rb'))
      expect(jira_logic).to include('([A-Z]{2,5}-\\d+)')
      expect(jira_logic).to include('skip_if_already_prefixed')
    end

    it 'raises when hooks directory does not exist' do
      bad_installer = described_class.new(git_dir: '/nonexistent/git/dir')
      expect { bad_installer.install }.to raise_error(GitHooks::Error, /Not a git repository/)
    end

    it 'skips unknown hook names' do
      installed = installer.install('pre-commit', 'nonexistent-hook')
      expect(installed).to eq(['pre-commit'])
    end
  end

  describe '#disabled_hooks' do
    it 'returns empty array when disabled file does not exist' do
      expect(installer.disabled_hooks).to eq([])
    end

    it 'returns hook names from disabled file' do
      disabled_path = File.join(@git_dir, GitHooks::Constants::DISABLED_FILE)
      File.write(disabled_path, "pre-commit\ncommit-msg\n")
      expect(installer.disabled_hooks).to contain_exactly('pre-commit', 'commit-msg')
    end
  end

  describe '#disable' do
    it 'creates disabled file and writes hook names' do
      installer.disable('pre-commit')
      expect(installer.disabled_hooks).to eq(['pre-commit'])
    end

    it 'appends new hook names without duplicating' do
      installer.disable('pre-commit')
      installer.disable('commit-msg', 'pre-commit')
      expect(installer.disabled_hooks).to contain_exactly('pre-commit', 'commit-msg')
    end

    it 'returns the hook names passed' do
      expect(installer.disable('pre-commit')).to eq(['pre-commit'])
    end
  end

  describe '#enable' do
    it 'removes hook names from disabled file' do
      installer.disable('pre-commit', 'commit-msg')
      installer.enable('pre-commit')
      expect(installer.disabled_hooks).to eq(['commit-msg'])
    end

    it 'deletes disabled file when all hooks enabled' do
      disabled_path = File.join(@git_dir, GitHooks::Constants::DISABLED_FILE)
      installer.disable('pre-commit')
      expect(File).to exist(disabled_path)
      installer.enable('pre-commit')
      expect(File).not_to exist(disabled_path)
    end

    it 'returns the hook names passed' do
      installer.disable('pre-commit')
      expect(installer.enable('pre-commit')).to eq(['pre-commit'])
    end
  end

  describe 'whitespace check feature' do
    it 'whitespace_check_enabled? is false when file does not exist' do
      expect(installer.whitespace_check_enabled?).to eq(false)
    end

    it 'enable_whitespace_check creates the flag file' do
      installer.enable_whitespace_check
      expect(installer.whitespace_check_enabled?).to eq(true)
      expect(File).to exist(File.join(@git_dir, GitHooks::Constants::FEATURE_FLAG_FILES['whitespace-check']))
    end

    it 'disable_whitespace_check removes the flag file' do
      installer.enable_whitespace_check
      installer.disable_whitespace_check
      expect(installer.whitespace_check_enabled?).to eq(false)
      expect(File).not_to exist(File.join(@git_dir, GitHooks::Constants::FEATURE_FLAG_FILES['whitespace-check']))
    end

    it 'disable_whitespace_check is a no-op when file does not exist' do
      expect { installer.disable_whitespace_check }.not_to raise_error
    end
  end

  describe 'rubocop check feature' do
    it 'rubocop_check_enabled? is false when file does not exist' do
      expect(installer.rubocop_check_enabled?).to eq(false)
    end

    it 'enable_rubocop_check creates the flag file' do
      installer.enable_rubocop_check
      expect(installer.rubocop_check_enabled?).to eq(true)
      expect(File).to exist(File.join(@git_dir, GitHooks::Constants::FEATURE_FLAG_FILES['rubocop-check']))
    end

    it 'disable_rubocop_check removes the flag file' do
      installer.enable_rubocop_check
      installer.disable_rubocop_check
      expect(installer.rubocop_check_enabled?).to eq(false)
      expect(File).not_to exist(File.join(@git_dir, GitHooks::Constants::FEATURE_FLAG_FILES['rubocop-check']))
    end

    it 'disable_rubocop_check is a no-op when file does not exist' do
      expect { installer.disable_rubocop_check }.not_to raise_error
    end
  end

  describe 'migrations check feature (on by default)' do
    it 'migrations_check_enabled? is true when disabled file does not exist' do
      expect(installer.migrations_check_enabled?).to eq(true)
    end

    it 'enable_migrations_check removes the disabled file' do
      installer.disable_migrations_check
      installer.enable_migrations_check
      expect(installer.migrations_check_enabled?).to eq(true)
      expect(File).not_to exist(File.join(@git_dir, GitHooks::Constants::FEATURE_FLAG_FILES['migrations-check']))
    end

    it 'disable_migrations_check creates the disabled file' do
      installer.disable_migrations_check
      expect(installer.migrations_check_enabled?).to eq(false)
      expect(File).to exist(File.join(@git_dir, GitHooks::Constants::FEATURE_FLAG_FILES['migrations-check']))
    end

    it 'enable_migrations_check is a no-op when already enabled' do
      expect { installer.enable_migrations_check }.not_to raise_error
      expect(installer.migrations_check_enabled?).to eq(true)
    end
  end

  describe 'find_git_dir (when git_dir not provided)' do
    it 'raises when not inside a git repository' do
      allow_any_instance_of(described_class).to receive(:find_git_dir).and_raise(
        GitHooks::Error, 'Not inside a git repository'
      )
      expect { described_class.new.install }.to raise_error(GitHooks::Error, /Not inside a git repository/)
    end
  end
end
