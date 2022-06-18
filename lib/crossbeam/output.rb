# frozen_string_literal: true

require_relative './error'

module Crossbeam
  # For forcing specific output after `#call`
  module Output
    # Used to include/extend modules into the current class
    #
    # @param base [Object]
    # @return [void]
    def self.included(base)
      base.class_eval do
        extend(ClassMethods)

        attr_accessor :output_param
      end
    end

    # Methods to load in the service object as class methods
    module ClassMethods
      # @return [Hash]
      CB_ALLOWED_OUTPUTS = [NilClass, String, Symbol].freeze
      # Used to specify an attribute/instance variable that should be used too return instead of @result
      #
      # @param param [String, Symbol]
      # @return [String, Symbol]
      def output(param)
        raise(ArguementError, 'A string or symbol is require for output') unless allowed_output?(param)

        @output_param = param
      end

      # Determine if the output attribute type is allowed
      #
      # @param output_type [String]
      # @return [Boolean]
      def allowed_output?(output_type)
        CB_ALLOWED_OUTPUTS.include?(output_type.class)
      end

      # Used to determine if a output parameter has been set or not
      #
      # @return [Boolean]
      def output?
        !output_param.nil?
      end

      # Determine the output to return if the instance_variable exists in the klass
      #
      # @return [Hash]
      def set_results_output
        return unless @klass
        return unless output? && @klass.instance_variable_defined?("@#{output_param}")

        @result.results = @klass.instance_variable_get("@#{output_param}")
      end

      # Add errors to @result.errors
      #
      # @return [Void]
      def build_error_list
        return unless @klass && @klass&.errors&.any?

        @klass.errors.each do |error|
          # options is usually passed with an ActiveRecord validation error
          # @example:
          #   <attribute=age, type=greater_than_or_equal_to, options={:value=>15, :count=>18}>
          @result.errors.add(error.attribute, error.message)
        end
        @klass.errors.clear
        reassign_results
      end

      # Reassign result, unless errors
      #
      # @return [Void]
      def reassign_results
        @result.results = nil
        @result.results = @klass.instance_variable_get("@#{output_param}") if specified_output?
      end

      # Does the klass have an assigned output
      #
      # @return [Boolean]
      def specified_output?
        output? && @klass.instance_variable_defined?("@#{output_param}")
      end

      # Used hold the parameter which can/will be used instead of @result
      #
      # @return [String, Symbol, nil]
      def output_param
        @output_param ||= nil
      end
    end
  end
end
