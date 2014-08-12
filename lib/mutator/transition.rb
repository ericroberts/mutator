module Mutator
  class Transition
    attr_reader :to, :from, :machine

    def initialize(to:, from:, machine:)
      @to, @from, @machine = to, from, machine
    end

    def valid?
      transitions.length > 0
    end

    def stateholder
      machine.stateholder
    end

    def ==(other)
      to == other.to && from == other.from && machine == other.machine
    end

    def eql?(other)
      public_send(:==, other)
    end

  protected

    def transitions
      machine.transitions.select do |t|
        t[:to] == to && t[:from].include?(from)
      end
    end
  end
end
