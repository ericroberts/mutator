module YASM
  class Machine
    attr_reader :stateholder

    def initialize(stateholder)
      @stateholder = stateholder
    end

    def valid?
      self.class.states.include? current_state
    end

    def current_state
      stateholder.state
    end

    def transition(to:, success: lambda { |_transition| }, failure: lambda { |_transition| })
      transition = Transition.new(to: to, from: current_state, machine: self)

      if transition.valid?
        stateholder.state = to
        success.call(transition)
        true
      else
        failure.call(transition)
        false
      end
    end

    def self.states
      self.transitions.map do |t|
        [t[:to], t[:from]]
      end.flatten.uniq
    end

    def states
      self.class.states
    end

    def transitions
      self.class.transitions
    end
  end
end
