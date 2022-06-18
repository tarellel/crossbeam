# frozen_string_literal: true

module Crossbeam
  # Error message that is raised to flag a Crossbeam service error
  #   used to create error messages for Crossbeam
  # @private
  class Error < StandardError
    # @return [String] Error message associated with StandardError
    attr_reader :context

    # Used to initializee an error message
    #
    # @param context [String, Hash]
    # @return [Object]
    def initialize(context = nil)
      @context = context
      super
    end
  end

  # Used to generate `ArguementError` exception
  # @private
  class ArguementError < Error; end
  # Used to generate `Failure` exception
  # @private
  class Failure < Error; end
  # Used to generate `NotImplementedError` exception
  # @private
  class NotImplementedError < Error; end
  # Used to generate `UndefinedMethod` exception
  # @private
  class UndefinedMethod < Error; end
end
