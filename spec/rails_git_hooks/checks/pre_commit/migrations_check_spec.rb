# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitHooks::Checks::PreCommit::MigrationsCheck do
  let(:config) { described_class.definition.default_config }
  let(:repo) { instance_double(GitHooks::Repository, root: Dir.pwd) }
  let(:context) { { repo: repo, applicable_files: files, argv: [], stdin: '' } }

  describe '#run' do
    context 'when no migration files staged' do
      let(:files) { ['app/models/user.rb'] }

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when migration and schema are both staged' do
      let(:files) { ['db/migrate/20240101000000_create_users.rb', 'db/schema.rb'] }

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when migration staged but schema not staged' do
      let(:files) { ['db/migrate/20240101000000_create_users.rb'] }

      it 'returns fail with message' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages.join).to match(/schema|db:migrate/i)
      end
    end

    context 'when structure.sql is staged with migration' do
      let(:files) { ['db/migrate/20240101000000_add_index.rb', 'db/structure.sql'] }

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end
  end
end
