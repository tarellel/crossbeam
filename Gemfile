# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in crossbeam.gemspec
gemspec

group :development, :test do
  gem 'sord'
end

group :development do
  gem 'fasterer', '>= 0.10'
  gem 'guard', '~> 2.18'
  gem 'guard-rspec'               # Runs tests against your application if spec files are changed
  gem 'guard-bundler'             # Runs bundle install if anything you Gemfile is changed
  gem 'guard-fasterer'
  gem 'guard-rubocop', '~> 1.5'   # Runs rubocop tests against your code as files are changed
  gem 'guard-yard'

  gem 'rubocop', '>= 1.27', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
  gem 'yard'

  gem 'debug'
  gem 'pry'
end

group :test do
  gem 'fuubar'
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'simplecov-tailwindcss', require: false
end
