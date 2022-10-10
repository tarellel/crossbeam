# typed: strong
# Crossbeam module to include with your service classes
module Crossbeam
  VERSION = T.let('0.1.0', T.untyped)

  # Used to include/extend modules into the current class
  # 
  # _@param_ `base`
  sig { params(base: Object).void }
  def self.included(base); end

  # Force the job to raise an exception and stop the rest of the service call
  # 
  # _@param_ `error`
  sig { params(error: String).void }
  def fail!(error); end

  # Used to return a list of errors for the current call
  sig { returns(T::Hash[T.untyped, T.untyped]) }
  def errors; end

  # Methods to load in the service object as class methods
  module ClassMethods
    # Used to initiate and service call
    # 
    # _@param_ `params`
    # 
    # _@param_ `options`
    sig { params(params: T::Array[Object], options: T::Hash[Symbol, Object], block: T.untyped).returns(T.any(Struct, Object)) }
    def call(*params, **options, &block); end

    # Call the klass's before/after callbacks, process errors, and call @klass
    sig { params(block: T.untyped).void }
    def run_callbacks_and_klass(&block); end

    # Process the error that was thrown by the object call
    # 
    # _@param_ `error` — error generated by the object call
    sig { params(error: Object).returns(T.any(Object, Crossbeam::Result)) }
    def process_error(error); end
  end

  # Error message that is raised to flag a Crossbeam service error
  #   used to create error messages for Crossbeam
  # @private
  class Error < StandardError
    # Used to initializee an error message
    # 
    # _@param_ `context`
    sig { params(context: T.nilable(T.any(String, T::Hash[T.untyped, T.untyped]))).void }
    def initialize(context = nil); end

    # _@return_ — Error message associated with StandardError
    sig { returns(String) }
    attr_reader :context
  end

  # Used to generate `ArguementError` exception
  # @private
  class ArguementError < Crossbeam::Error
  end

  # Used to generate `Failure` exception
  # @private
  class Failure < Crossbeam::Error
  end

  # Used to generate `NotImplementedError` exception
  # @private
  class NotImplementedError < Crossbeam::Error
  end

  # Used to generate `UndefinedMethod` exception
  # @private
  class UndefinedMethod < Crossbeam::Error
  end

  # Used to allow adding errors to the service call similar to ActiveRecord errors
  class Errors < Hash
    # Add an error to the list of errors
    # 
    # _@param_ `key` — the key/attribute for the error. (Usually ends up being :base)
    # 
    # _@param_ `value` — a description of the error
    # 
    # _@param_ `_opts` — additional attributes that get ignored
    sig { params(key: T.any(String, Symbol), value: T.any(String, Symbol), _opts: T::Hash[T.untyped, T.untyped]).returns(T::Hash[T.untyped, T.untyped]) }
    def add(key, value, _opts = {}); end

    # Add multiple errors to the error hash
    # 
    # _@param_ `errors`
    # 
    # _@return_ — , Array]
    sig { params(errors: T::Hash[String, Symbol]).returns(T::Hash[T.untyped, T.untyped]) }
    def add_multiple_errors(errors); end

    # Look through and return a list of all errorr messages
    sig { returns(T.any(T::Hash[T.untyped, T.untyped], T::Array[T.untyped])) }
    def each; end

    # Return a full list of error messages
    sig { returns(T::Array[String]) }
    def full_messages; end

    # Used to convert the list of errors to a string
    sig { returns(String) }
    def to_s; end

    # Convert the message to a full error message
    # 
    # _@param_ `attribute`
    # 
    # _@param_ `message`
    sig { params(attribute: T.any(String, Symbol), message: String).returns(String) }
    def full_message(attribute, message); end
  end

  # For forcing specific output after `#call`
  module Output
    # Used to include/extend modules into the current class
    # 
    # _@param_ `base`
    sig { params(base: Object).void }
    def self.included(base); end

    # Methods to load in the service object as class methods
    module ClassMethods
      CB_ALLOWED_OUTPUTS = T.let([NilClass, String, Symbol].freeze, T.untyped)

      # Used to specify an attribute/instance variable that should be used too return instead of @result
      # 
      # _@param_ `param`
      sig { params(param: T.any(String, Symbol)).returns(T.any(String, Symbol)) }
      def output(param); end

      # Determine if the output attribute type is allowed
      # 
      # _@param_ `output_type`
      sig { params(output_type: String).returns(T::Boolean) }
      def allowed_output?(output_type); end

      # Used to determine if a output parameter has been set or not
      sig { returns(T::Boolean) }
      def output?; end

      # Determine the output to return if the instance_variable exists in the klass
      sig { returns(T::Hash[T.untyped, T.untyped]) }
      def set_results_output; end

      # Add errors to @result.errors
      sig { void }
      def build_error_list; end

      # Reassign result, unless errors
      sig { void }
      def reassign_results; end

      # Does the klass have an assigned output
      sig { returns(T::Boolean) }
      def specified_output?; end

      # Used hold the parameter which can/will be used instead of @result
      sig { returns(T.nilable(T.any(String, Symbol))) }
      def output_param; end
    end
  end

  # Used as a data container to hold a service calls results, errors, etc.
  # class Result < Struct.new(:called, :errors, :failure, :results)
  class Result < Struct
    # Used to initialize a service calls results, errors, and stats
    # 
    # _@param_ `called`
    # 
    # _@param_ `errors`
    # 
    # _@param_ `failure`
    # 
    # _@param_ `results`
    sig do
      params(
        called: T::Boolean,
        errors: T.nilable(T::Hash[T.untyped, T.untyped]),
        failure: T::Boolean,
        results: T.nilable(Object)
      ).void
    end
    def initialize(called: false, errors: nil, failure: false, results: nil); end

    # The serivce can't officially be a failure/pass if it hasn't been "called"
    sig { returns(T::Boolean) }
    def called?; end

    # Determine if the service call has any errors
    sig { returns(T::Boolean) }
    def errors?; end

    # Determine if the service call has failed to uccessfully complete
    sig { returns(T::Boolean) }
    def failure?; end

    # Determine if the service call has successfully ran
    sig { returns(T::Boolean) }
    def success?; end

    # Return if the service has any issues (errors or failure)
    sig { returns(T::Boolean) }
    def issues?; end

    # Returns the value of attribute called
    sig { returns(Object) }
    attr_accessor :called

    # Returns the value of attribute errors
    sig { returns(Object) }
    attr_accessor :errors

    # Returns the value of attribute failure
    sig { returns(Object) }
    attr_accessor :failure

    # Returns the value of attribute results
    sig { returns(Object) }
    attr_accessor :results
  end

  # Callbacks before/after the services `call` is called
  module Callbacks
    # Used to include/extend modules into the current class
    # 
    # _@param_ `base`
    sig { params(base: Object).void }
    def self.included(base); end

    # Methods to load in the service object as class methods
    module ClassMethods
      # Add callback `before` method or block
      # 
      # _@param_ `callbacks`
      sig { params(callbacks: T::Hash[T.untyped, T.untyped], block: T.untyped).void }
      def before(*callbacks, &block); end

      # Add callback `after` method or block
      # 
      # _@param_ `callbacks`
      sig { params(callbacks: T::Hash[T.untyped, T.untyped], block: T.untyped).void }
      def after(*callbacks, &block); end

      # Call all callbacks before `#call` is referenced (methods, blocks, etc.)
      sig { void }
      def run_before_callbacks; end

      # Call and run all callbacks after `#call` has ran
      sig { void }
      def run_after_callbacks; end

      # Create a list of `after` callback methods and/or blocks
      sig { returns(T::Array[T.untyped]) }
      def after_callbacks; end

      # Create a list of `before` callback methods and/or blocks
      sig { returns(T::Array[T.untyped]) }
      def before_callbacks; end

      # Loopthrough and run all the classes listed callback methods
      # 
      # _@param_ `callbacks` — a list of methods to be called
      sig { params(callbacks: T::Array[T.any(String, Symbol)]).void }
      def run_callbacks(callbacks); end

      # Run callback m method or block
      # 
      # _@param_ `callback`
      # 
      # _@param_ `options`
      sig { params(callback: Symbol, options: T::Hash[T.untyped, T.untyped]).void }
      def run_callback(callback, *options); end
    end
  end
end

# Used to generate a Rails service object
class CrossbeamGenerator < Rails::Generators::Base
  sig { void }
  def generate_service; end

  sig { void }
  def generate_test; end

  # Returns a string to use as the service classes file name
  sig { returns(String) }
  def filename; end
end
