# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Crossbeam::Error, 'Crossbeam::Error' do
  let(:error_message) { 'something happened' }

  describe 'Error' do
    it do
      expect{ raise(Crossbeam::Error, error_message) }
        .to raise_error(Crossbeam::Error)
    end
  end

  describe 'ArguementError' do
    it do
      expect{ raise(Crossbeam::ArguementError, error_message) }
        .to raise_error(Crossbeam::ArguementError)
    end
  end

  describe 'Failure' do
    it do
      expect{ raise(Crossbeam::Failure, error_message) }
        .to raise_error(Crossbeam::Failure)
    end
  end

  describe 'NotImplementedError' do
    it do
      expect{ raise(Crossbeam::NotImplementedError, error_message) }
        .to raise_error(Crossbeam::NotImplementedError)
    end
  end
end