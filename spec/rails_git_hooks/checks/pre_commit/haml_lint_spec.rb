# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'tmpdir'

RSpec.describe GitHooks::Checks::PreCommit::HamlLint do
  let(:config) { described_class.definition.default_config.merge('command' => %w[bundle exec haml-lint]) }
  let(:repo_root) { Dir.mktmpdir('haml_lint_spec') }
  let(:repo) { instance_double(GitHooks::Repository, root: repo_root) }
  let(:context) { { repo: repo, applicable_files: files, argv: [], stdin: '' } }

  after { FileUtils.rm_rf(repo_root) }

  describe '#run' do
    context 'when no HAML files in applicable_files' do
      let(:files) { ['config/settings.yml'] }

      it 'returns pass without running command' do
        check = described_class.new(config: config, context: context)
        expect(Open3).not_to receive(:capture2e)
        expect(check.run).to be_pass
      end
    end

    context 'when command succeeds' do
      let(:haml_path) { File.join(repo_root, 'app/views/foo.html.haml') }
      let(:files) { [haml_path] }

      before do
        FileUtils.mkdir_p(File.dirname(haml_path))
        File.write(haml_path, '%div ok')
        allow(Open3).to receive(:capture2e).and_return(['', double(success?: true)])
      end

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when command fails' do
      let(:haml_path) { File.join(repo_root, 'app/views/foo.html.haml') }
      let(:files) { [haml_path] }

      before do
        FileUtils.mkdir_p(File.dirname(haml_path))
        File.write(haml_path, '%div ok')
        allow(Open3).to receive(:capture2e)
                    .and_return(["app/views/foo.html.haml:1 [W] LineLength: Line is too long\n", double(success?: false)])
      end

      it 'returns fail with command output' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages).to include('app/views/foo.html.haml:1 [W] LineLength: Line is too long')
      end
    end
  end
end
