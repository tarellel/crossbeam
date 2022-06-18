# frozen_string_literal: true

require 'active_model'
require 'dry-initializer'

# Crossbeam required modules
require_relative 'crossbeam/callbacks'
require_relative 'crossbeam/error' # exceptions
require_relative 'crossbeam/errors' # errors
# For forcing specific output after `#call`
require_relative 'crossbeam/output'
require_relative 'crossbeam/result'
require_relative 'crossbeam/version'

require 'debug'

# Crossbeam module to include with your service classes
module Crossbeam
  # Used to include/extend modules into the current class
  #
  # @param base [Object]
  # @return [void]
  def self.included(base)
    base.class_eval do
      include(ActiveModel::Validations) # Used to add validation errors to a class
      extend(Dry::Initializer) # Used to allow for easy attribute initializations
      extend(ClassMethods) # Class methods used to initialize the service call
      include(Output)
      include(Callbacks) # Callbacks that get called before/after `.call` is referenced

      # Holds the service call results and current class call for Crossbeam Instance
      attr_reader :result, :klass
    end
  end

  # Methods to load in the service object as class methods
  module ClassMethods
    # Used to initiate and service call
    #
    # @param params [Array<Object>]
    # @param options [Hash<Symbol, Object>]
    # @return [Struct, Object]
    def call(*params, **options, &block)
      @result = Crossbeam::Result.new(called: true)
      @klass = new(*params, **options)
      run_callbacks_and_klass(&block)
      @result
    rescue Crossbeam::Failure => e
      process_error(e)
    end

    # Call the klass's before/after callbacks, process errors, and call @klass
    #
    # @return [Void]
    def run_callbacks_and_klass(&block)
      # Call all the classes `before`` callbacks
      run_before_callbacks
      # Initialize and run the classes call method
      @result.results = @klass.call(&block)
      # build @result.errors if errors were added
      build_error_list if @klass.errors.any?
      # re-assign @result if output was set
      set_results_output
      # Call all the classes `after` callbacks
      run_after_callbacks
    end

    # Process the error that was thrown by the object call
    #
    # @param error [Object] error generated by the object call
    # @return [Object, Crossbeam::Result]
    def process_error(error)
      @result.failure = true
      @result.errors.add(:failure, error.to_s)
      @result.results = nil
      @result
    end
  end

  # Force the job to raise an exception and stop the rest of the service call
  #
  # @param error [String]
  # @return [void]
  def fail!(error)
    raise(Crossbeam::Failure, error)
  end

  %w[called failure errors issues success].each do |attr|
    # Used to determine the current state of the service call
    #
    # @return [Boolean]
    define_method("#{attr}?") do
      return false unless @result

      attr = attr.to_s
      @result.send("#{attr}?".to_sym) || false
    end
  end

  # Used to return a list of errors for the current call
  #
  # @return [Hash]
  def errors
    return {} unless @result

    @result.errors
  end
end
