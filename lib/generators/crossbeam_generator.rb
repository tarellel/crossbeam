# frozen_string_literal: true

# Only define the generators if part of rails app to prevent causing an excceeption
if defined?(Rails)
  require 'rails/generators'

  # Used to generate a Rails service object
  class CrossbeamGenerator < Rails::Generators::Base
    source_root File.expand_path(File.join('.', 'templates'), File.dirname(__FILE__))

    argument :class_name, type: :string
    argument :attributes, type: :array, default: [], banner: 'field[:type]'
    desc 'Generate a Crossbeam service class'

    # @return [void]
    def generate_service
      template 'service_class.rb.tt', "app/services/#{filename}.rb", force: true
    end

    # @return [void]
    def generate_test
      return unless Rails&.application&.config&.generators&.test_framework == :rspec

      template 'service_spec.rb.tt', "spec/services/#{filename}_spec.rb", force: true
    end

    private

    # Returns a string to use as the service classes file name
    #
    # @return [String]
    def filename
      class_name.underscore
    end
  end
end
