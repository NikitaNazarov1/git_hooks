# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'tmpdir'

RSpec.describe GitHooks::Installer do
  around do |example|
    project_root = File.expand_path('../..', __dir__)
    Dir.mktmpdir('rails_git_hooks_spec', project_root) do |tmpdir|
      @git_dir = File.join(tmpdir, 'repo_git')
      @hooks_dir = File.join(@git_dir, 'hooks')
      FileUtils.mkdir_p(@hooks_dir)
      example.run
    end
  end

  let(:installer) { described_class.new(git_dir: @git_dir) }

  describe '.available_hook_names' do
    it 'returns hook names from templates directory' do
      expect(described_class.available_hook_names).to contain_exactly('commit-msg', 'pre-commit', 'pre-push')
    end
  end

  describe '#available_hooks' do
    it 'returns same as .available_hook_names' do
      expect(installer.available_hooks).to eq(described_class.available_hook_names)
    end
  end

  describe '#install' do
    it 'installs hooks that have enabled checks in merged config (defaults when no yml)' do
      installed = installer.install

      expect(installed).to contain_exactly('commit-msg', 'pre-commit')
      expect(File).to be_executable(File.join(@hooks_dir, 'commit-msg'))
      expect(File).to be_executable(File.join(@hooks_dir, 'pre-commit'))
      expect(File).not_to exist(File.join(@hooks_dir, 'pre-push'))
      expect(File).to exist(File.join(@hooks_dir, 'rails_git_hooks', 'runtime.rb'))
      expect(File).to exist(File.join(@hooks_dir, 'rails_git_hooks', 'checks', 'pre_commit.rb'))
    end

    it 'writes thin hook bootstrap scripts' do
      installer.install

      content = File.read(File.join(@hooks_dir, 'commit-msg'))
      expect(content).to include("require File.join(hooks_dir, 'rails_git_hooks', 'runtime')")
      expect(content).to include('GitHooks::Runtime.execute(:commit_msg')
    end

    it 'raises when hooks directory does not exist' do
      bad_installer = described_class.new(git_dir: '/nonexistent/git/dir')
      expect { bad_installer.install }.to raise_error(GitHooks::Error, /Not a git repository/)
    end

    it 'installs hooks that have enabled checks in config (e.g. pre-push when RunTests enabled)' do
      root = File.dirname(@git_dir)
      File.write(File.join(root, '.rails_git_hooks.yml'), <<~YAML)
        PrePush:
          RunTests:
            enabled: true
      YAML

      installed = installer.install

      expect(installed).to include('pre-push')
      expect(File).to exist(File.join(@hooks_dir, 'pre-push'))
    end
  end
end
