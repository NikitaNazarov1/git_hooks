# frozen_string_literal: true

require_relative 'lib/rails_git_hooks/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails_git_hooks'
  spec.version       = GitHooks::VERSION
  spec.authors       = ['Nikita Nazarov']
  spec.email         = ['nikenor11@gmail.com']

  spec.summary       = 'Most useful git hooks for Rails and Ruby projects'
  spec.description   = 'Installs most useful git hooks for Rails and Ruby projects'
  spec.homepage      = 'https://github.com/NikitaNazarov1/rails_git_hooks'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/NikitaNazarov1/rails_git_hooks'
  spec.metadata['changelog_uri'] = 'https://github.com/NikitaNazarov1/rails_git_hooks/blob/main/CHANGELOG.md'

  spec.files = Dir['lib/**/*', 'bin/*', 'templates/**/*'] + %w[README.md LICENSE CHANGELOG.md]
  spec.bindir        = 'bin'
  spec.executables   = ['rails_git_hooks']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
end
