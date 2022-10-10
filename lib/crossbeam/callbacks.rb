# frozen_string_literal: true

require_relative './error'

module Crossbeam
  # Callbacks before/after the services `call` is called
  module Callbacks
    # Used to include/extend modules into the current class
    #
    # @param base [Object]
    # @return [void]
    def self.included(base)
      base.class_eval do
        extend(ClassMethods)

        attr_accessor :klass
      end
    end

    # Methods to load in the service object as class methods
    module ClassMethods
      # Add callback `before` method or block
      #
      # @param callbacks [Hash]
      # @return [Void]
      # @yield An optional block to instance_exec(&block) || instance_eval(&block)
      def before(*callbacks, &block)
        callbacks << block if block
        callbacks.each { |callback| before_callbacks << callback }
      end

      # Add callback `after` method or block
      #
      # @param callbacks [Hash]
      # @return [Void]
      # @yield An optional block to instance_exec(&block) || instance_eval(&block)
      def after(*callbacks, &block)
        callbacks << block if block
        callbacks.each { |callback| after_callbacks << callback }
      end

      # Call all callbacks before `#call` is referenced (methods, blocks, etc.)
      #
      # @return [Void]
      def run_before_callbacks
        # run_callbacks(self.class.before_callbacks)
        run_callbacks(before_callbacks)
      end

      # Call and run all callbacks after `#call` has ran
      #
      # @return [Void]
      def run_after_callbacks
        run_callbacks(after_callbacks)
      end

      # Create a list of `after` callback methods and/or blocks
      #
      # @return [Array]
      def after_callbacks
        @after_callbacks ||= []
      end

      # Create a list of `before` callback methods and/or blocks
      #
      # @return [Array]
      def before_callbacks
        @before_callbacks ||= []
      end

      # Loopthrough and run all the classes listed callback methods
      #
      # @param callbacks [Array<String, Symbol>] a list of methods to be called
      # @return [Void]
      def run_callbacks(callbacks)
        callbacks.each { |callback| run_callback(callback) }
      end

      private

      # Run callback m method or block
      #
      # @param callback [Symbol]
      # @param options [Hash]
      # @return [Void]
      def run_callback(callback, *options)
        # Ensure the initialize instance class has been called and passed
        return unless @klass

        # callback.is_a?(Symbol) ? send(callback, *options) : instance_exec(*options, &callback)
        if [String, Symbol].include?(callback.class) && @klass.respond_to?(callback.to_sym)
          @klass.send(callback, *options)
        elsif callback.is_a?(Proc)
          @klass.instance_exec(*options, &callback)
        end
      end
    end
  end
end
