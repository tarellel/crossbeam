# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Crossbeam, 'crossbeam#output' do
  let(:without_output_return) do
    Crossbeam::Result.new(called: true, errors: {}, failure: false)
  end

  class OutputSample
    include Crossbeam

    param  :name, proc(&:to_s)
    param  :age, default: proc { 10 }

    # Attribute/Instance Variable to return
    output :age

    def call
      @age += 1
      "Hello, #{name}! You are #{age} years old."
    end
  end

  class WithoutOutputOutputSample
    include Crossbeam

    param  :name, proc(&:to_s)
    param  :age, default: proc { 10 }

    def call
      "Hello, #{name}! You are #{age} years old."
    end
  end
  # let(:new_class){ OutputSample_class.new('Dave', 2) }

  describe 'output' do
    it 'with param' do
      result = OutputSample.call('Dave')
      expect(result.results).to eq(11)
      expect(result.results).to_not eq(without_output_return)
    end

    it 'without output' do
      result = WithoutOutputOutputSample.call('Dave')
      without_output_return.results = 'Hello, Dave! You are 10 years old.'
      expect(result.results).to_not eq(11)
      expect(result).to eq(without_output_return)
    end
  end
end
