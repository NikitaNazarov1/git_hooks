# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe GitHooks::Checks::PreCommit::DebuggerCheck do
  let(:config) { described_class.definition.default_config }
  let(:repo_root) { Dir.mktmpdir('debugger_check') }
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

    context 'when Ruby file has no debugger' do
      let(:files) { [File.join(repo_root, 'app/models/user.rb')] }

      before do
        path = File.join(repo_root, 'app/models/user.rb')
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, 'class User; end')
      end

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when Ruby file contains binding.pry' do
      let(:files) { [File.join(repo_root, 'app/models/user.rb')] }

      before do
        path = File.join(repo_root, 'app/models/user.rb')
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, "def foo\n  binding.pry\nend")
      end

      it 'returns fail with message' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages.first).to match(/user\.rb.*debugger/)
      end
    end
  end
end
