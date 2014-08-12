require 'spec_helper'
require 'support/test_classes'

describe Mutator::Transition do
  subject { Mutator::Transition.new(to: to, from: from, machine: machine) }
  let(:to) { :initial_state }
  let(:from) { :second_state }
  let(:machine) { Mutator::Stateholder.new(stateholder) }
  let(:stateholder) { Stateholder.new }

  describe '#initialize' do
    it 'should not error' do
      expect { subject }.to_not raise_error
    end

    context 'arguments' do
      [:to, :from, :machine].each do |attr|
        it "should require you to pass #{attr}" do
          args = { to: :something, from: :something, machine: :something }
          args.delete attr
          expect { subject.class.new(args) }.to raise_error ArgumentError, "must provide #{attr}"
        end
      end
    end
  end

  [:to, :from, :machine].each do |attr|
    describe "##{attr}" do
      it 'should be set to what it was passed' do
        expect(subject.public_send(attr)).to eq public_send(attr)
      end
    end
  end

  describe '#call' do
    context 'transition is valid' do
      let(:to) { :second_state }
      let(:from) { :initial_state }

      it 'should return the new state' do
        expect(subject.call).to eq :second_state
      end
    end

    context 'transition is invalid' do
      let(:to) { :third_state }
      let(:from) { :initial_state }

      it 'should return the new state' do
        expect(subject.call).to be nil
      end
    end
  end

  describe '#valid?' do
    context 'valid transition' do
      let(:to) { :second_state }
      let(:from) { :initial_state }

      it 'should be true' do
        expect(subject).to be_valid
      end
    end

    context 'invalid transition' do
      let(:to) { :third_state }
      let(:from) { :initial_state }

      it 'should be false' do
        expect(subject).to_not be_valid
      end
    end
  end

  describe '#stateholder' do
    it 'should return the machine stateholder' do
      expect(subject.stateholder).to eq machine.stateholder
    end
  end

  shared_examples 'equal' do |method|
    it 'should consider itself equal to another transition that is the same' do
      transition1 = subject.class.new(to: to, from: from, machine: machine)
      transition2 = subject.class.new(to: to, from: from, machine: machine)

      expect(transition1.public_send(method, transition2)).to be true
    end
  end

  describe '#==' do
    it_should_behave_like 'equal', :==
  end

  describe '#eql?' do
    it_should_behave_like 'equal', :eql?
  end
end
