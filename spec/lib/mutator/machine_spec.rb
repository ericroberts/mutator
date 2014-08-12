require 'spec_helper'
require 'mutator'

class Stateholder
  attr_writer :state

  def state
    @state ||= :initial_state
  end
end

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

describe Mutator::Stateholder do
  subject { Mutator::Stateholder.new(stateholder) }
  let(:stateholder) { Stateholder.new }

  describe '#initialize' do
    it 'should not error' do
      expect { subject }.to_not raise_error
    end
  end

  describe '#stateholder' do
    it 'should return the stateholder it was passed' do
      expect(subject.stateholder).to eq stateholder
    end
  end

  describe '#valid?' do
    it 'should be valid if the state exists in states list' do
      subject.stateholder.state = :initial_state
      expect(subject).to be_valid
    end

    it 'should not be valid for a state not in states list' do
      subject.stateholder.state = :foobar
      expect(subject).to_not be_valid
    end
  end

  describe '#current_state' do
    it 'should return the stateholder state' do
      expect(subject.current_state).to eq stateholder.state
    end
  end

  describe '#transition' do
    context 'valid transition' do
      let(:from) { :initial_state }
      let(:to) { :second_state }

      before { subject.stateholder.state = from }

      it 'should update state' do
        expect(subject.stateholder.state).to eq from
        subject.transition(to: to)
        expect(subject.stateholder.state).to eq to
      end

      it 'should return true' do
        expect(subject.transition(to: to)).to be true
      end

      context 'with success policy' do
        let(:success) { double }

        before { allow(success).to receive(:call).and_return(true) }

        it 'should still update state' do
          expect(subject.stateholder.state).to eq from
          subject.transition(to: to, success: success)
          expect(subject.stateholder.state).to eq to
        end

        it 'should still return true' do
          expect(subject.transition(to: to, success: success)).to be true
        end

        it 'should call the success policy' do
          expect(success).to receive(:call).and_return(true)
          subject.transition(to: to, success: success)
        end
      end
    end

    context 'invalid transition' do
      let(:from) { :initial_state }
      let(:to) { :third_state }

      before { subject.stateholder.state = from }

      it 'should not update state' do
        expect(subject.stateholder.state).to eq from
        subject.transition(to: to)
        expect(subject.stateholder.state).to eq from
      end

      it 'should return false' do
        expect(subject.transition(to: to)).to be false
      end

      context 'with failure policy' do
        let(:failure) { double }

        before { allow(failure).to receive(:call).and_return(true) }

        it 'should still not update state' do
          expect(subject.stateholder.state).to eq from
          subject.transition(to: to, failure: failure)
          expect(subject.stateholder.state).to eq from
        end

        it 'should still return false' do
          expect(subject.transition(to: to, failure: failure)).to be false
        end

        it 'should call the failure policy' do
          expect(failure).to receive(:call).and_return(true)
          subject.transition(to: to, failure: failure)
        end

        context 'when policy is to raise an exception' do
          before { expect(failure).to receive(:call).and_raise(Exception) }
          
          it 'should raise an exception' do
            expect { subject.transition(to: to, failure: failure) }.to raise_error Exception
          end
        end
      end
    end
  end

  describe '#states' do
    it 'should respond to states' do
      expect(subject).to respond_to :states
    end

    it 'should extract states from transitions' do
      expect(subject.states.sort).to eq [
        :initial_state,
        :second_state,
        :third_state
      ].sort
    end
  end

  describe '#transitions' do
    it 'should respond to' do
      expect(subject).to respond_to :transitions
    end
  end
end
