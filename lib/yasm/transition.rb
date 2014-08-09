module YASM
  class Transition
    attr_reader :to, :from, :machine

    def initialize(to:, from:, machine:)
      @to, @from, @machine = to, from, machine
    end

    def valid?
      valid_transitions.present?
    end

  protected

    def valid_transitions
      machine.valid_transitions.select do |t|
        t[:to] == to && t[:from].include?(from)
      end
    end
  end
end
