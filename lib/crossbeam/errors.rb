# frozen_string_literal: true

require_relative 'error'

module Crossbeam
  # Very similar to ActiveModel errors
  # https://github.com/rails/rails/blob/main/activemodel/lib/active_model/validations.rb

  # Used to allow adding errors to the service call similar to ActiveRecord errors
  class Errors < Hash
    # Add an error to the list of errors
    #
    # @param key [String, Symbol] the key/attribute for the error. (Usually ends up being :base)
    # @param value [String, Symbol] a description of the error
    # @param _opts [Hash] additional attributes that get ignored
    # @return [Hash]
    def add(key, value, _opts = {})
      self[key] ||= []
      self[key] << value
      self[key].uniq!
    end

    # Add multiple errors to the error hash
    #
    # @param errors [Hash<String, Symbol>]
    # @return [Hash], Array]
    def add_multiple_errors(errors)
      errors.each do |key, values|
        if values.is_a?(String)
          add(key, values)
        elsif [Array, Hash].include?(values.class)
          values.each { |value| add(key, value) }
        end
      end
    end

    # Look through and return a list of all errorr messages
    #
    # @return [Hash, Array]
    def each
      each_key do |field|
        self[field].each { |message| yield field, message }
      end
    end

    # Return a full list of error messages
    #
    # @return [Array<String>]
    def full_messages
      map { |attribute, message| full_message(attribute, message) }.freeze
    end

    # Used to convert the list of errors to a string
    #
    # @return [String]
    def to_s
      return '' unless self&.any?

      full_messages.join("\n")
    end

    private

    # Convert the message to a full error message
    #
    # @param attribute [String, Symbol]
    # @param message [String]
    # @return [String]
    def full_message(attribute, message)
      return message if attribute == :base

      attr_name = attribute.to_s.tr('.', '_').capitalize
      format('%<attr>s %<msg>s', attr: attr_name, msg: message)
    end
  end
end
