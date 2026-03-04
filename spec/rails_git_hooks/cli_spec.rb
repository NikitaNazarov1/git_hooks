# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitHooks::CLI do
  def run_cli(argv)
    described_class.run(argv)
  end

  describe 'help' do
    it 'prints help for --help' do
      expect { run_cli(['--help']) }.to output(/rails_git_hooks - Install git hooks/).to_stdout
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
         .and(including('commit-msg')).and(including('pre-commit'))
         .and(including('pre-push'))).to_stdout
    end
  end

  describe 'install' do
    it 'outputs installed hooks and passes hook names to Installer' do
      installer = instance_double(GitHooks::Installer, install: %w[commit-msg pre-commit pre-push])
      allow(GitHooks::Installer).to receive(:new).with(jira_project: nil).and_return(installer)

      expect { run_cli(['install']) }.to output(a_string_including('Installed hooks:').and(including('pre-push'))).to_stdout
      expect(installer).to have_received(:install).with(no_args)
    end

    it 'passes --jira to Installer' do
      installer = instance_double(GitHooks::Installer, install: ['commit-msg'])
      allow(GitHooks::Installer).to receive(:new).with(jira_project: 'MYPROJ').and_return(installer)

      expect { run_cli(['install', '--jira', 'MYPROJ', 'commit-msg']) }.to output("Installed hooks: commit-msg\n").to_stdout
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

  describe 'disable' do
    it 'disables hooks and prints confirmation' do
      installer = instance_double(GitHooks::Installer, disable: ['pre-commit'])
      allow(GitHooks::Installer).to receive(:new).and_return(installer)

      expect { run_cli(%w[disable pre-commit]) }.to output("Disabled: pre-commit\n").to_stdout
      expect(installer).to have_received(:disable).with('pre-commit')
    end

    it 'exits with usage when no hooks given' do
      expect { run_cli(['disable']) }.to raise_error(SystemExit) do |e|
        expect(e.status).to eq(1)
      end
    end
  end

  describe 'enable' do
    it 'enables hooks and prints confirmation' do
      installer = instance_double(GitHooks::Installer, enable: ['pre-commit'])
      allow(GitHooks::Installer).to receive(:new).and_return(installer)

      expect { run_cli(%w[enable pre-commit]) }.to output("Enabled: pre-commit\n").to_stdout
      expect(installer).to have_received(:enable).with('pre-commit')
    end

    it 'exits with usage when no hooks given' do
      expect { run_cli(['enable']) }.to raise_error(SystemExit) do |e|
        expect(e.status).to eq(1)
      end
    end
  end

  describe 'disabled' do
    it 'prints "No hooks disabled." when none disabled' do
      installer = instance_double(GitHooks::Installer, disabled_hooks: [])
      allow(GitHooks::Installer).to receive(:new).and_return(installer)

      expect { run_cli(['disabled']) }.to output("No hooks disabled.\n").to_stdout
    end

    it 'prints disabled hook names' do
      installer = instance_double(GitHooks::Installer, disabled_hooks: %w[pre-commit commit-msg])
      allow(GitHooks::Installer).to receive(:new).and_return(installer)

      expect { run_cli(['disabled']) }.to output("Disabled hooks: pre-commit, commit-msg\n").to_stdout
    end
  end

  describe 'enable whitespace-check' do
    it 'enables whitespace-check and prints confirmation' do
      installer = instance_double(GitHooks::Installer, enable: [])
      allow(GitHooks::Installer).to receive(:new).and_return(installer)
      allow(installer).to receive(:enable_whitespace_check)

      expect { run_cli(%w[enable whitespace-check]) }.to output("Enabled: whitespace-check\n").to_stdout
      expect(installer).to have_received(:enable_whitespace_check)
    end
  end

  describe 'disable whitespace-check' do
    it 'disables whitespace-check and prints confirmation' do
      installer = instance_double(GitHooks::Installer, disable: [])
      allow(GitHooks::Installer).to receive(:new).and_return(installer)
      allow(installer).to receive(:disable_whitespace_check)

      expect { run_cli(%w[disable whitespace-check]) }.to output("Disabled: whitespace-check\n").to_stdout
      expect(installer).to have_received(:disable_whitespace_check)
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
