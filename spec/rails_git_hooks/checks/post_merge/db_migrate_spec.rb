# frozen_string_literal: true

require 'spec_helper'
require 'open3'

RSpec.describe GitHooks::Checks::PostMerge::DbMigrate do
  let(:config) { described_class.definition.default_config.merge('command' => %w[bundle exec rails db:migrate]) }
  let(:repo) { instance_double(GitHooks::Repository, root: Dir.pwd) }
  let(:context) { { repo: repo, applicable_files: files, argv: [], stdin: '' } }

  describe '#run' do
    context 'when no migration or schema files in applicable set' do
      let(:files) { [] }

      it 'returns pass without running command' do
        check = described_class.new(config: config, context: context)
        expect(Open3).not_to receive(:capture2e)
        expect(check.run).to be_pass
      end
    end

    context 'when migration file in applicable set and command succeeds' do
      let(:files) { ['db/migrate/20240101000000_add_index.rb'] }

      before do
        allow(Open3).to receive(:capture2e).and_return(['', double(success?: true)])
      end

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end
  end
end
