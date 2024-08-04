# frozen_string_literal: true

# Only define the generators if part of rails app to prevent causing an excceeption
if defined?(Rails)
  require 'rails/generators'

  # Used to generate a Rails service object
  class CrossbeamGenerator < Rails::Generators::Base
    source_root File.expand_path(File.join('.', 'templates'), File.dirname(__FILE__))

    argument :class_name, type: :string
    argument :attributes, type: :array, default: [], banner: 'field[:type]'
    class_option :command, type: :boolean, default: false
    desc 'Generate a Crossbeam service class'

    # @return [void]
    def generate_service
      template 'service_class.rb.tt', "app/#{class_directory}/#{filename}.rb", force: true
    end

    # @return [void]
    def generate_test
      return unless Rails.application&.config&.generators&.test_framework == :rspec

      template 'service_spec.rb.tt', "spec/#{class_directory}/#{filename}_spec.rb", force: true
    end

    private

    # Used to deteremine if the class is a command vs service class
    #
    # @return [String]
    def class_directory
      @class_directory ||= options[:command] ? 'commands' : 'services'
    end

    # Return the label of the class type
    #
    # @return [String]
    def class_type_label
      @class_type_label ||= options[:command] ? 'command' : 'service'
    end

    # Returns a string to use as the service classes file name
    #
    # @return [String]
    def filename
      class_name.underscore
    end
  end
end
