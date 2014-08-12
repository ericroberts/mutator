require 'spec_helper'
require 'mutator/machine'

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

  it 'should initialize without error' do
    expect { subject }.to_not raise_error
  end

  describe '#stateholder' do
    it 'should return the stateholder it was passed' do
      expect(subject.stateholder).to eq stateholder
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

  describe '#current_state' do
    it 'should return the stateholder state' do
      expect(subject.current_state).to eq stateholder.state
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
end
