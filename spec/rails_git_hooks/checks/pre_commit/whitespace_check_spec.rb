# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe GitHooks::Checks::PreCommit::WhitespaceCheck do
  let(:config) { described_class.definition.default_config }
  let(:repo_root) { Dir.mktmpdir('whitespace_check') }
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

    context 'when file has no trailing whitespace or conflict markers' do
      let(:files) { [File.join(repo_root, 'app/foo.rb')] }

      before do
        path = File.join(repo_root, 'app/foo.rb')
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, "def foo\n  true\nend\n")
      end

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when file has trailing whitespace' do
      let(:files) { [File.join(repo_root, 'app/foo.rb')] }

      before do
        path = File.join(repo_root, 'app/foo.rb')
        FileUtils.mkdir_p(File.dirname(path))
        # Line ending with space (no newline after) triggers the check
        File.write(path, "def foo\n  true  ")
      end

      it 'returns fail with message' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages.first).to match(/trailing whitespace/)
      end
    end

    context 'when file has conflict marker' do
      let(:files) { [File.join(repo_root, 'app/foo.rb')] }

      before do
        path = File.join(repo_root, 'app/foo.rb')
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, "def foo\n<<<<<<< HEAD\n  old\n=======\n  new\n>>>>>>> branch\nend\n")
      end

      it 'returns fail with message' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages.any? { |m| m.include?('conflict marker') }).to be true
      end
    end
  end
end
