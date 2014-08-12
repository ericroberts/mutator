require 'spec_helper'

module Mutator
  class Stateholder < Machine
    def self.transitions
      [
        { from: [:initial_state], to: :second_state },
        { from: [:second_state], to: :third_state }
      ]
    end
  end
end

class Stateholder
  include Mutator::Helpers

  def state
    @state ||= :initial_state
  end

  def self.where(*args)
  end
end

describe Mutator::Helpers do
  subject { Mutator::Helpers }

  describe '.included' do
    let(:base) { Stateholder }

    it 'should not error' do
      expect { subject.included(base) }.to_not raise_error
    end
  end

  context 'when included' do
    subject { Stateholder.new }

    describe '#machine' do
      it 'should respond to it' do
        expect(subject).to respond_to :machine
      end

      it 'should return a Mutator::Stateholder object' do
        expect(subject.machine).to be_a Mutator::Stateholder
      end
    end

    [:initial_state, :second_state, :third_state].each do |state|
      describe ".#{state}" do
        it 'should respond to the method' do
          expect(subject.class).to respond_to state
        end

        it 'should call where on the stateholder with the state as an argument' do
          expect(subject.class).to receive(:where).with(state: state).and_return(Stateholder.new)
          subject.class.public_send(state)
        end
      end
    end
  end
end
