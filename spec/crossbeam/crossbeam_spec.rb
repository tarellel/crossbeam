# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Crossbeam, 'crossbeam#module' do
  let(:sample_class) do
    class Sample
      include Crossbeam
    end
  end
  let(:new_class){ sample_class.new }

  # Sample class to test declarations
  class Foo
    include Crossbeam

    param  :name, proc(&:to_s)
    param  :age

    option :dogs, default: proc { 0 }

    def call
      "Hello, #{name}! You are #{age} years old and have #{dogs} dogs."
    end
  end

  describe 'default params' do
    # used to test parameters and keyword attributes with dry-initializer
    let(:foo){ foo = Foo.call('Fred', 12, dogs: 3) }
    it do
      expect(foo.called?).to be_truthy
      expect(foo.errors?).to be_falsy
      expect(foo.results).to eq('Hello, Fred! You are 12 years old and have 3 dogs.')
    end
  end


  describe 'without call' do
    let(:new_sample) { sample_class.new }

    it { expect(new_sample.called?).to be_falsy }
    it { expect(new_sample.errors?).to be_falsy }
    it { expect(new_sample.failure?).to be_falsy }
    it { expect(new_sample.send(:issues?)).to be_falsy }
    it { expect(new_sample.success?).to be_falsy }
  end
end