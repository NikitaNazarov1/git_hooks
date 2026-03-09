# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe GitHooks::Checks::PreCommit::YAMLFormatCheck do
  let(:config) { described_class.definition.default_config }
  let(:repo_root) { Dir.mktmpdir('yaml_check') }
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

    context 'when YAML file is valid' do
      let(:files) { [File.join(repo_root, 'config/settings.yml')] }

      before do
        path = File.join(repo_root, 'config/settings.yml')
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, "foo: bar\n")
      end

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when YAML file has syntax error' do
      let(:files) { [File.join(repo_root, 'config/bad.yml')] }

      before do
        path = File.join(repo_root, 'config/bad.yml')
        FileUtils.mkdir_p(File.dirname(path))
        # Unclosed quote triggers Psych::SyntaxError
        File.write(path, 'foo: "unclosed')
      end

      it 'returns fail with message' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages.first).to match(/bad\.yml|syntax|indent/i)
      end
    end
  end
end
