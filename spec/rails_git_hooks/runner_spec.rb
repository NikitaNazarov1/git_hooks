# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitHooks::Runner do
  let(:repo) do
    instance_double(
      GitHooks::Repository,
      root: Dir.pwd,
      staged_files: ['app/models/user.rb', 'config/settings.yml'],
      current_branch: 'feature/APD-123'
    )
  end

  describe '#run' do
    it 'applies include/exclude filters before running file-based checks' do
      definition = GitHooks::CheckRegistry.find!('json-format-check')
      overrides = instance_double(GitHooks::OverrideConfig)
      dependencies = instance_double(GitHooks::DependencyChecker)
      policy = instance_double(GitHooks::PolicyResolver)
      check_instance = instance_double(definition.klass.name, run: GitHooks::CheckResult.pass)

      allow(GitHooks::CheckRegistry).to receive(:for).with(:pre_commit).and_return([definition])
      allow(GitHooks::OverrideConfig).to receive(:new).with(repo: repo).and_return(overrides)
      allow(overrides).to receive(:config_for).and_return(
        definition.default_config.merge('include' => ['app/**/*.rb'], 'exclude' => ['config/**/*'])
      )
      allow(GitHooks::DependencyChecker).to receive(:new).with(repo: repo).and_return(dependencies)
      allow(dependencies).to receive(:check).and_return(GitHooks::CheckResult.pass)
      allow(GitHooks::PolicyResolver).to receive(:new).and_return(policy)
      allow(policy).to receive(:resolve) { |result, _config| result }
      allow(definition.klass).to receive(:new).and_return(check_instance)

      described_class.new(repo: repo, hook_name: :pre_commit, argv: [], stdin: '').run

      expect(definition.klass).to have_received(:new).with(
        config: hash_including('include' => ['app/**/*.rb']),
        context: hash_including(applicable_files: ['app/models/user.rb'])
      )
    end

    it 'treats failures as warnings when on_fail is warn' do
      definition = GitHooks::CheckRegistry.find!('debugger-check')
      overrides = instance_double(GitHooks::OverrideConfig)
      dependencies = instance_double(GitHooks::DependencyChecker)
      check_result = GitHooks::CheckResult.fail(messages: ['problem'])

      allow(GitHooks::CheckRegistry).to receive(:for).with(:pre_commit).and_return([definition])
      allow(GitHooks::OverrideConfig).to receive(:new).and_return(overrides)
      allow(overrides).to receive(:config_for).and_return(definition.default_config)
      allow(GitHooks::DependencyChecker).to receive(:new).and_return(dependencies)
      allow(dependencies).to receive(:check).and_return(GitHooks::CheckResult.pass)
      allow(definition.klass).to receive(:new).and_return(instance_double(definition.klass.name, run: check_result))

      exit_code = nil
      expect do
        exit_code = described_class.new(repo: repo, hook_name: :pre_commit, argv: [], stdin: '').run
      end.to output(/Warning \(DebuggerCheck\):/).to_stderr

      expect(exit_code).to eq(0)
    end

    it 'suppresses successful output when quiet is true' do
      definition = GitHooks::CheckRegistry.find!('rubocop-check')
      overrides = instance_double(GitHooks::OverrideConfig)
      dependencies = instance_double(GitHooks::DependencyChecker)
      policy = instance_double(GitHooks::PolicyResolver)

      allow(GitHooks::CheckRegistry).to receive(:for).with(:pre_commit).and_return([definition])
      allow(GitHooks::OverrideConfig).to receive(:new).and_return(overrides)
      allow(overrides).to receive(:config_for)
        .and_return(definition.default_config.merge('enabled' => true, 'quiet' => true))
      allow(GitHooks::DependencyChecker).to receive(:new).and_return(dependencies)
      allow(dependencies).to receive(:check).and_return(GitHooks::CheckResult.pass)
      allow(GitHooks::PolicyResolver).to receive(:new).and_return(policy)
      allow(policy).to receive(:resolve) { |result, _config| result }
      double_run = instance_double(definition.klass.name, run: GitHooks::CheckResult.pass)
      allow(definition.klass).to receive(:new).and_return(double_run)

      expect do
        described_class.new(repo: repo, hook_name: :pre_commit, argv: [], stdin: '').run
      end.not_to output.to_stderr
    end
  end
end
