module Mutator
  class Transition
    attr_reader :to, :from, :machine

    def initialize opts
      @to, @from, @machine = opts.fetch(:to), opts.fetch(:from), opts.fetch(:machine)
    end

    def call
      stateholder.state = to if valid?
    end

    def valid?
      transitions.length > 0
    end

    def stateholder
      machine.stateholder
    end

    def == other
      to == other.to && from == other.from && machine == other.machine
    end

    def eql? other
      public_send :==, other
    end

  protected

    def transitions
      machine.transitions.select do |transition|
        transition[:to] == to && transition[:from].include?(from)
      end
    end
  end
end
