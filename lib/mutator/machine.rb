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
      options = extract(options)
      success, failure, transition = options.values

      if transition.call
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

  protected

    def extract(options)
      to = options[:to]
      fail ArgumentError, 'must provide state to transition to' unless to

      {
        success: lambda { |_| },
        failure: lambda { |_| },
        transition: Transition.new(
          to: to,
          from: current_state,
          machine: self
        )
      }.merge(options)
    end
  end
end
