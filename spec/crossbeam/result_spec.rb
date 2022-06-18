# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Crossbeam::Result, 'Crossbeam::Result' do
  let(:new_result){ described_class.new }
  let(:error_message) { 'something happened' }

  class TestFail
    include Crossbeam

    def call
      # create a failure
      fall_and_fail unless 1 > 2
    end

    # private

    def fall_and_fail
      fail!('1 is less than 2')
    end
  end

  context 'on initialize' do
    describe 'called' do
      it { expect(new_result.called).to be_falsy }
      it { expect(new_result.called?).to be_falsy }
    end

    describe 'errors' do
      it { expect(new_result.errors).to be_empty }
      it { expect(new_result.errors?).to be_falsy }
    end
  end

  describe 'failure/fail' do
    it { expect(new_result.failure?).to be_falsy}
    it do
      new_result.called = true
      new_result.failure = true
      expect(new_result.failure?).to be_truthy
    end

    it 'required to be called' do
      new_result.called = false
      new_result.failure = true
      expect(new_result.failure?).to be_falsy
    end

    it do
      new_result.called = true
      new_result.failure = true
      expect(new_result.failure?).to be_truthy
    end

    # a result needs to be called in order to be a failure
    it { expect(new_result.failure?).to be_falsy }
    #it do
    #  expect{ new_result.fail!(error_message) }.to raise_error(Crossbeam::Failure, error_message)
#
    #  # Should be a failure when an error is raised
    #  # expect(new_result.failure?).to be_truthy
    #end
  end

  describe 'success' do
    it { expect(new_result.success?).to be_falsy }

    # Add issues and check for success
    it do
      new_result.instance_variable_set(:@result, true)
      expect(new_result.send(:success?)).to be_falsy
    end
  end

  describe 'issues' do
    it { expect(new_result.send(:issues?)).to be_falsy }

    it 'failure' do
      new_result.failure = true
      expect(new_result.send(:issues?)).to be_truthy
    end
  end

  describe 'fail!' do
    let(:test_call) { TestFail.call }
    # it 'it should have an issue if any errors have beeen added' do
    #   # raise Crossbeam::Failure, 'An invalid user lookup was specified.'
    # end

    it { expect(test_call.failure?).to be_truthy }
    it { expect(test_call.errors.full_messages).to eq(['Failure 1 is less than 2']) }
    it { expect(test_call.results).to eq(nil) }
  end

  describe 'results' do
    it { expect(new_result.results).to be_falsy }
  end

  describe 'errors#add errors.add_multiple_errors' do
    let(:multiple_errors) do
      { base: 'foo bar', other: error_message }.freeze
    end

    let(:multiple_nested_errors_array) do
      { other: ['foo', 'bar'] }.freeze
    end

    let(:multiple_based_nested_errors) do
      { base: ['foo', 'bar'] }.freeze
    end

    it { expect(new_result.errors?).to be_falsy }
    it 'add base error' do
      new_result.errors.add(:base, error_message)
      expect(new_result.errors?).to be_truthy
      expect(new_result.errors.full_messages).to eq([error_message])
    end

    it 'add other error' do
      new_result.errors.add(:other, error_message)
      expect(new_result.errors.full_messages).to eq(['Other something happened'])
    end

    it 'add multiple errors' do
      new_result.errors.add_multiple_errors(multiple_errors)
      expect(new_result.errors.full_messages).to eq(['foo bar', 'Other something happened'])
    end

    it 'mutliple nested errors' do
      new_result.errors.add_multiple_errors(multiple_nested_errors_array)
      expect(new_result.errors.full_messages).to eq(['Other foo', 'Other bar'])
    end

    it 'mutliple nested base errors' do
      new_result.errors.add_multiple_errors(multiple_based_nested_errors)
      expect(new_result.errors).to eq({ base: ['foo', 'bar']})
      expect(new_result.errors.full_messages).to eq(['foo', 'bar'])
    end
  end
end