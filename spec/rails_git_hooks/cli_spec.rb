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

  describe 'list' do
    it 'prints available hook names' do
      expect do
        run_cli(['list'])
      end.to output(a_string_including('Available hooks:')
         .and(including('commit-msg'))
         .and(including('Available checks:'))
         .and(including('rubocop-check'))).to_stdout
    end
  end

  describe 'install' do
    it 'outputs installed hooks and passes no args to Installer (default: commit-msg + pre-commit)' do
      installer = instance_double(GitHooks::Installer, install: %w[commit-msg pre-commit])
      allow(GitHooks::Installer).to receive(:new).with(no_args).and_return(installer)

      expect { run_cli(['install']) }.to output("Installed hooks: commit-msg, pre-commit\n").to_stdout
      expect(installer).to have_received(:install).with(no_args)
    end

    it 'passes hook names to Installer' do
      installer = instance_double(GitHooks::Installer, install: ['commit-msg'])
      allow(GitHooks::Installer).to receive(:new).with(no_args).and_return(installer)

      expect { run_cli(%w[install commit-msg]) }.to output("Installed hooks: commit-msg\n").to_stdout
      expect(installer).to have_received(:install).with('commit-msg')
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

  describe 'enable' do
    it 'enables a check and prints confirmation' do
      repo = instance_double(GitHooks::Repository)
      config = instance_double(GitHooks::OverrideConfig)
      definition = instance_double(GitHooks::CheckDefinition)
      allow(GitHooks::Repository).to receive(:new).and_return(repo)
      allow(GitHooks::OverrideConfig).to receive(:new).with(repo: repo).and_return(config)
      allow(GitHooks::CheckRegistry).to receive(:find!).with('rubocop-check').and_return(definition)
      allow(config).to receive(:set_option)

      expect { run_cli(%w[enable rubocop-check]) }.to output("Enabled: rubocop-check\n").to_stdout
      expect(config).to have_received(:set_option).with(definition, 'enabled', true)
    end

    it 'exits with usage when no check given' do
      expect { run_cli(['enable']) }.to raise_error(SystemExit) do |e|
        expect(e.status).to eq(1)
      end
    end
  end

  describe 'disable' do
    it 'disables a check and prints confirmation' do
      repo = instance_double(GitHooks::Repository)
      config = instance_double(GitHooks::OverrideConfig)
      definition = instance_double(GitHooks::CheckDefinition)
      allow(GitHooks::Repository).to receive(:new).and_return(repo)
      allow(GitHooks::OverrideConfig).to receive(:new).with(repo: repo).and_return(config)
      allow(GitHooks::CheckRegistry).to receive(:find!).with('migrations-check').and_return(definition)
      allow(config).to receive(:set_option)

      expect { run_cli(%w[disable migrations-check]) }.to output("Disabled: migrations-check\n").to_stdout
      expect(config).to have_received(:set_option).with(definition, 'enabled', false)
    end

    it 'exits with usage when no check given' do
      expect { run_cli(['disable']) }.to raise_error(SystemExit) do |e|
        expect(e.status).to eq(1)
      end
    end
  end

  describe 'set' do
    it 'updates a check option' do
      repo = instance_double(GitHooks::Repository)
      config = instance_double(GitHooks::OverrideConfig)
      definition = instance_double(GitHooks::CheckDefinition)
      allow(GitHooks::Repository).to receive(:new).and_return(repo)
      allow(GitHooks::OverrideConfig).to receive(:new).with(repo: repo).and_return(config)
      allow(GitHooks::CheckRegistry).to receive(:find!).with('debugger-check').and_return(definition)
      allow(config).to receive(:set_option)

      expect { run_cli(%w[set debugger-check on_fail fail]) }.to output("Updated: debugger-check on_fail=fail\n").to_stdout
      expect(config).to have_received(:set_option).with(definition, 'on_fail', 'fail')
    end

    it 'exits with usage when arguments are missing' do
      expect { run_cli(%w[set debugger-check on_fail]) }.to raise_error(SystemExit) do |e|
        expect(e.status).to eq(1)
      end
    end
  end

  describe 'show-config' do
    it 'prints effective merged config' do
      repo = instance_double(GitHooks::Repository)
      config = instance_double(GitHooks::OverrideConfig)
      allow(GitHooks::Repository).to receive(:new).and_return(repo)
      allow(GitHooks::OverrideConfig).to receive(:new).with(repo: repo).and_return(config)
      allow(config).to receive(:effective_config).and_return({ 'PreCommit' => { 'DebuggerCheck' => { 'enabled' => true } } })

      expect { run_cli(['show-config']) }.to output(/PreCommit/).to_stdout
      expect(config).to have_received(:effective_config).with(GitHooks::CheckRegistry.all)
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
