# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe GitHooks::Checks::PreCommit::JSONFormatCheck do
  let(:config) { described_class.definition.default_config }
  let(:repo_root) { Dir.mktmpdir('json_check') }
  let(:repo) { instance_double(GitHooks::Repository, root: repo_root) }
  let(:context) { { repo: repo, applicable_files: files, argv: [], stdin: '' } }

  after { FileUtils.rm_rf(repo_root) }

  describe '#run' do
    context 'when no applicable files' do
      let(:files) { [] }

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when JSON file is valid' do
      let(:files) { [File.join(repo_root, 'package.json')] }

      before do
        path = File.join(repo_root, 'package.json')
        File.write(path, '{"name": "app"}')
      end

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when JSON file is invalid' do
      let(:files) { [File.join(repo_root, 'data.json')] }

      before do
        path = File.join(repo_root, 'data.json')
        File.write(path, '{ invalid json')
      end

      it 'returns fail with message' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages.first).to match(/data\.json|parse|json/i)
      end
    end
  end
end
