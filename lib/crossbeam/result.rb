# frozen_string_literal: true

require 'active_model'
# Crossbeam files
require_relative 'error'
require_relative 'errors'

module Crossbeam
  # Used as a data container to hold a service calls results, errors, etc.
  # class Result < Struct.new(:called, :errors, :failure, :results)
  Result = Struct.new(:called, :errors, :failure, :results) do
    # extend ActiveModel::Naming
    # include ActiveModel::Conversion
    # attr_accessor :called, :errors, :failure, :results

    # Used to initialize a service calls results, errors, and stats
    #
    # @param called [Boolean]
    # @param errors [Hash]
    # @param failure [Boolean]
    # @param results [Object]
    def initialize(called: false, errors: nil, failure: false, results: nil)
      super(called, errors, failure, results)

      self.called = called
      self.errors = Crossbeam::Errors.new
      self.failure = failure
      self.results = nil
    end

    # The serivce can't officially be a failure/pass if it hasn't been "called"
    #
    # @return [Boolean]
    def called?
      called || false
    end

    # Determine if the service call has any errors
    #
    # @return [Boolean]
    def errors?
      (errors.is_a?(Hash) && errors.any?) || false
    end

    # Determine if the service call has failed to uccessfully complete
    #
    # @return [Boolean]
    def failure?
      called? && issues?
    end

    # Determine if the service call has successfully ran
    #
    # @return [Boolean]
    def success?
      called? && !issues?
    end

    private

    # Return if the service has any issues (errors or failure)
    #
    # @return [Boolean]
    def issues?
      errors? || failure
    end
  end
end
