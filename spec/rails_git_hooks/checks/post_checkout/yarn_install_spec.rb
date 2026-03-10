# frozen_string_literal: true

require 'spec_helper'
require 'open3'

RSpec.describe GitHooks::Checks::PostCheckout::YarnInstall do
  let(:config) { described_class.definition.default_config.merge('command' => %w[yarn install]) }
  let(:repo) { instance_double(GitHooks::Repository, root: Dir.pwd) }
  let(:context) { { repo: repo, applicable_files: files, argv: [], stdin: '' } }

  describe '#run' do
    context 'when no applicable files (package.json not in changed set)' do
      let(:files) { [] }

      it 'returns pass without running command' do
        check = described_class.new(config: config, context: context)
        expect(Open3).not_to receive(:capture2e)
        expect(check.run).to be_pass
      end
    end

    context 'when package.json in applicable files and command succeeds' do
      let(:files) { ['package.json'] }

      before do
        allow(Open3).to receive(:capture2e).and_return(['', double(success?: true)])
      end

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when yarn.lock changed and command fails' do
      let(:files) { ['yarn.lock'] }

      before do
        allow(Open3).to receive(:capture2e).and_return(["error Command failed with exit code 1.\n", double(success?: false)])
      end

      it 'returns fail with output' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages).to include('error Command failed with exit code 1.')
      end
    end
  end
end
