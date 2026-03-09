# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitHooks::Checks::PreCommit::DefaultBranch do
  let(:config) { described_class.definition.default_config }
  let(:repo) { instance_double(GitHooks::Repository, root: Dir.pwd, current_branch: branch) }
  let(:context) { { repo: repo, applicable_files: [], argv: [], stdin: '' } }

  describe '#run' do
    context 'when on a feature branch' do
      let(:branch) { 'feature/APD-123' }

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
        expect(check.run.messages).to be_empty
      end
    end

    context 'when on main' do
      let(:branch) { 'main' }

      it 'returns fail with message' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages).to include(match(/main.*not allowed|feature branch/))
      end
    end

    context 'when on master' do
      let(:branch) { 'master' }

      it 'returns fail with message' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages).to include(match(/master.*not allowed|feature branch/))
      end
    end
  end
end
