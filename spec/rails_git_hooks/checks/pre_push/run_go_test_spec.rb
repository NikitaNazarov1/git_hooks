# frozen_string_literal: true

require 'spec_helper'
require 'open3'

RSpec.describe GitHooks::Checks::PrePush::RunGoTest do
  let(:config) { described_class.definition.default_config.merge('command' => %w[go test ./...]) }
  let(:repo) { instance_double(GitHooks::Repository, root: Dir.pwd) }
  let(:context) { { repo: repo, applicable_files: [], argv: [], stdin: '' } }

  describe '#run' do
    context 'when command succeeds' do
      before do
        allow(Open3).to receive(:capture2e).and_return(['ok', double(success?: true)])
      end

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when command fails' do
      before do
        allow(Open3).to receive(:capture2e).and_return(
          ["--- FAIL: TestFoo (0.00s)\n    foo_test.go:10: expected 1, got 2\n", double(success?: false)]
        )
      end

      it 'returns fail with command output' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages).to include(match(/FAIL|expected/))
      end
    end
  end
end
