# frozen_string_literal: true

require_relative 'lib/crossbeam/version'

Gem::Specification.new do |spec|
  spec.name = 'crossbeam'
  spec.version = Crossbeam::VERSION
  spec.authors = ['Brandon Hicks']
  spec.email = ['tarellel@gmail.com']
  spec.summary = 'An easy way to create and run service objects with callbacks, validations, errors, and responses'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/tarellel/crossbeam'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7'
  if spec.respond_to?(:metadata)
    spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issue"
    spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  # files required and associated with the gem
  spec.extra_rdoc_files = %w[CHANGELOG.md README.md LICENSE.txt]
  spec.files = Dir['lib/**/*', 'CHANGELOG.md', 'LICENSE.txt', 'README.md', 'defs.rbi']
  spec.require_paths = %w[lib]
  spec.test_files = spec.files.grep(%r{^spec/})

  # For errors, validations, and object initializations
  spec.add_dependency 'activemodel', '>= 3.0'
  spec.add_dependency 'dry-initializer', '~> 3.1'

  # Linting, Testing, etc.
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'rubocop-performance'
end
