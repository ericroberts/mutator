module Mutator
  class Transition
    attr_reader :to, :from, :machine

    def initialize(opts)
      [:to, :from, :machine].each do |attr|
        fail ArgumentError, "must provide #{attr}" unless opts[attr]
      end
      @to, @from, @machine = opts[:to], opts[:from], opts[:machine]
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
