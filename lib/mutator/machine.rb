module Mutator
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

    def transition(options)
      defaults = {
        success: lambda { |_| },
        failure: lambda { |_| }
      }
      opts = defaults.merge(options)
      fail ArgumentError, 'must provide state to transition to' unless opts[:to]

      transition = Transition.new(to: opts[:to], from: current_state, machine: self)

      if transition.valid?
        stateholder.state = opts[:to]
        opts[:success].call(transition)
        true
      else
        opts[:failure].call(transition)
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
