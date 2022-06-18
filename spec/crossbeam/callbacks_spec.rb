# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Crossbeam::Callbacks, 'Crossbeam::Callbacks' do
  let(:sample_class) do
    class Sample
      include Crossbeam
    end
  end
  let(:new_class){ sample_class.new }

  class PersonAfter
    include Crossbeam

    # used to test assignments and set an initial value for the callbacks
    option :age, default: proc { 0 }
    attr_accessor :age

    after do
      @age = 1
    end

    def call
      @age = 0
    end


  end

  class PersonBefore
    include Crossbeam

    option :age, default: proc { 0 }

    before :set_age
    before :skipped_because_private


    def call
      @age = 12 unless @age.positive?
      @age
    end

    def set_age
      @age = 5
    end

    private

    def skipped_because_private
      @age = 17
    end
  end

  context 'before' do
    it { expect(PersonBefore.call.results).to eq(5) }
  end

  context 'after' do
    it { expect(PersonAfter.call.results).to eq(0) }
  end
end
