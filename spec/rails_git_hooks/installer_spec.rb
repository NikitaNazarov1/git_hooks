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

  describe '#available_hooks' do
    it 'returns hook names from templates directory' do
      expect(installer.available_hooks).to contain_exactly('commit-msg', 'pre-commit', 'pre-push')
    end
  end

  describe '#install' do
    it 'installs all hooks when no names given' do
      installed = installer.install
      expect(installed).to contain_exactly('commit-msg', 'pre-commit', 'pre-push')
      expect(File).to be_executable(File.join(@hooks_dir, 'pre-commit'))
      expect(File).to be_executable(File.join(@hooks_dir, 'commit-msg'))
      expect(File).to be_executable(File.join(@hooks_dir, 'pre-push'))
    end

    it 'installs only requested hooks' do
      installed = installer.install('pre-commit')
      expect(installed).to eq(['pre-commit'])
      expect(File).to exist(File.join(@hooks_dir, 'pre-commit'))
      expect(File).not_to exist(File.join(@hooks_dir, 'commit-msg'))
    end

    it 'substitutes JIRA_PROJECT_KEY in commit-msg with jira_project' do
      installer_with_jira = described_class.new(git_dir: @git_dir, jira_project: 'MYPROJ')
      installer_with_jira.install('commit-msg')
      content = File.read(File.join(@hooks_dir, 'commit-msg'))
      expect(content).to include('MYPROJ-\d+')
      expect(content).not_to include('JIRA_PROJECT_KEY')
    end

    it 'uses ENV GIT_HOOKS_JIRA_PROJECT when jira_project not passed' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GIT_HOOKS_JIRA_PROJECT').and_return('ENVPROJ')
      installer_env = described_class.new(git_dir: @git_dir)
      installer_env.install('commit-msg')
      content = File.read(File.join(@hooks_dir, 'commit-msg'))
      expect(content).to include('ENVPROJ-\d+')
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
      disabled_path = File.join(@git_dir, GitHooks::Installer::DISABLED_FILE)
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
      disabled_path = File.join(@git_dir, GitHooks::Installer::DISABLED_FILE)
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

  describe 'find_git_dir (when git_dir not provided)' do
    it 'raises when not inside a git repository' do
      allow_any_instance_of(described_class).to receive(:find_git_dir).and_raise(
        GitHooks::Error, 'Not inside a git repository'
      )
      expect { described_class.new.install }.to raise_error(GitHooks::Error, /Not inside a git repository/)
    end
  end
end
