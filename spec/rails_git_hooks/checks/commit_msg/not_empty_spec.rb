# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe GitHooks::Checks::CommitMsg::NotEmpty do
  let(:config) { described_class.definition.default_config }
  let(:repo_root) { Dir.mktmpdir('not_empty') }
  let(:repo) { instance_double(GitHooks::Repository, root: repo_root) }
  let(:msg_path) { File.join(repo_root, 'COMMIT_EDITMSG') }
  let(:context) { { repo: repo, applicable_files: [], argv: [msg_path], stdin: '' } }

  after { FileUtils.rm_rf(repo_root) }

  describe '#run' do
    context 'when argv has no message file' do
      let(:context) { { repo: repo, applicable_files: [], argv: [], stdin: '' } }

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when message has content' do
      before { File.write(msg_path, "Fix bug\n") }

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when message is empty' do
      before { File.write(msg_path, '') }

      it 'returns fail with message' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages).to include('Commit message must not be empty.')
      end
    end

    context 'when message is only whitespace' do
      before { File.write(msg_path, "  \n\t\n") }

      it 'returns fail' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_fail
      end
    end

    context 'when message is only comment lines' do
      before { File.write(msg_path, "# Please enter the commit message\n# comment\n") }

      it 'returns fail' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_fail
      end
    end
  end
end
