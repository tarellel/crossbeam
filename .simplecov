# frozen_string_literal: true

require 'simplecov' unless defined?(SimpleCov)
require 'simplecov-tailwindcss' unless defined?(SimpleCov::Formatter::TailwindFormatter)

SimpleCov.start do
  add_filter('/bin/')
  add_filter('/docs/')
  add_filter('/lib/unmh/crossbeam/version.rb')
  add_filter('/spec')
  add_filter('/spec/support/')
end
SimpleCov.minimum_coverage(75)
SimpleCov.use_merging(false)
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::TailwindFormatter
])
