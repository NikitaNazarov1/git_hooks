# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitHooks::CLI do
  def run_cli(argv)
    described_class.run(argv)
  end

  describe 'help' do
    it 'prints help for --help' do
      expect { run_cli(['--help']) }.to output(/rails_git_hooks - Install configurable Git hooks/).to_stdout
    end

    it 'prints help for -h' do
      expect { run_cli(['-h']) }.to output(/Usage:/).to_stdout
    end

    it 'prints help for no arguments' do
      expect { run_cli([]) }.to output(/Commands:/).to_stdout
    end
  end

  describe 'install' do
    it 'calls Installer#install with no args and outputs installed hooks' do
      installer = instance_double(GitHooks::Installer, install: %w[commit-msg pre-commit pre-push])
      allow(GitHooks::Installer).to receive(:new).with(no_args).and_return(installer)

      expect { run_cli(['install']) }.to output("Installed hooks: commit-msg, pre-commit, pre-push\n").to_stdout
      expect(installer).to have_received(:install)
    end

    it 'warns and exits on Installer error' do
      allow(GitHooks::Installer).to receive(:new).and_return(instance_double(GitHooks::Installer).tap do |i|
        allow(i).to receive(:install).and_raise(GitHooks::Error, 'Not a git repository')
      end)

      expect { run_cli(['install']) }.to output(/Error: Not a git repository/).to_stderr
                                                                              .and(raise_error(SystemExit) { |e|
                                                                                     expect(e.status).to eq(1)
                                                                                   })
    end
  end

  describe 'init' do
    it 'creates the override config file' do
      repo = instance_double(GitHooks::Repository)
      config = instance_double(GitHooks::OverrideConfig)
      allow(GitHooks::Repository).to receive(:new).and_return(repo)
      allow(GitHooks::OverrideConfig).to receive(:new).with(repo: repo).and_return(config)
      allow(config).to receive(:init)

      expect { run_cli(['init']) }.to output(/Initialized \.rails_git_hooks\.yml/).to_stdout
      expect(config).to have_received(:init)
    end
  end

  describe 'unknown command' do
    it 'warns and exits with 1' do
      expect { run_cli(['unknown']) }.to raise_error(SystemExit) do |e|
        expect(e.status).to eq(1)
      end
    end
  end
end
