# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'tmpdir'

RSpec.describe GitHooks::OverrideConfig do
  around do |example|
    Dir.mktmpdir('rails_git_hooks_config_spec') do |tmpdir|
      @repo = Struct.new(:root, :config_path, :local_config_path).new(
        tmpdir,
        File.join(tmpdir, '.rails_git_hooks.yml'),
        File.join(tmpdir, '.rails_git_hooks.local.yml')
      )
      example.run
    end
  end

  let(:config) { described_class.new(repo: @repo) }
  let(:rubocop) { GitHooks::CheckRegistry.find!('rubocop-check') }

  describe '#config_for' do
    it 'merges sparse overrides with code defaults' do
      File.write(@repo.config_path, <<~YAML)
        PreCommit:
          ALL:
            quiet: true
          RuboCop:
            enabled: true
      YAML

      result = config.config_for(rubocop)

      expect(result['enabled']).to eq(true)
      expect(result['quiet']).to eq(true)
      expect(result['on_fail']).to eq('fail')
    end

    it 'merges local config on top of main config (local wins)' do
      File.write(@repo.config_path, <<~YAML)
        PreCommit:
          RuboCop:
            enabled: true
      YAML
      File.write(@repo.local_config_path, <<~YAML)
        PreCommit:
          RuboCop:
            enabled: false
            quiet: false
      YAML

      result = config.config_for(rubocop)

      expect(result['enabled']).to eq(false)
      expect(result['quiet']).to eq(false)
    end
  end

  describe '#set_option' do
    it 'writes sparse overrides only when value differs from default' do
      config.set_option(rubocop, 'enabled', true)

      expect(File.read(@repo.config_path)).to include('enabled: true')

      config.set_option(rubocop, 'enabled', false)
      expect(File.exist?(@repo.config_path)).to eq(false)
    end
  end
end
