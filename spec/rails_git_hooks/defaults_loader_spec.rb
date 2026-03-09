# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitHooks::DefaultsLoader do
  describe '.config_for' do
    it 'returns default config for a known check' do
      config = described_class.config_for('PreCommit', 'RuboCop')

      expect(config).to be_a(Hash)
      expect(config['enabled']).to eq(false)
      expect(config['quiet']).to eq(true)
      expect(config['description']).to include('RuboCop')
    end

    it 'returns nil for unknown section' do
      expect(described_class.config_for('UnknownHook', 'SomeCheck')).to be_nil
    end

    it 'returns nil for unknown config_name in known section' do
      expect(described_class.config_for('PreCommit', 'NonExistent')).to be_nil
    end
  end
end
