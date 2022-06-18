# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Crossbeam::Errors, 'Crossbeam::Error' do
  class ErrorClass
    include Crossbeam

    def initialize(name, age)
      @name = name
      @age = age
    end

    def call
      errors.add(:age, "#{@name} is a minor") if @age < 18
      errors.add(:base, 'something something somthing')
    end
  end

  subject { ErrorClass.call('James', 12) }
  let(:expected_error_hash) do
    { age: ['James is a minor'],
      base: ['something something somthing']
    }.freeze
  end
  let(:full_error_list) do
    ['Age James is a minor', 'something something somthing'].freeze
  end
  let(:errors_string) do
    "Age James is a minor\nsomething something somthing"
  end

  context 'when errors' do
    describe '#errors' do
      it { expect(subject.errors).to eq(expected_error_hash) }
    end

    describe '#full_messages' do
      it { expect(subject.errors.full_messages).to eq(full_error_list)}
    end

    describe '#to_s' do
      it { expect(subject.errors.to_s).to eq(errors_string) }
    end
  end
end