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

class Stateholder
  include Mutator::Helpers

  attr_writer :state

  def state
    @state ||= :initial_state
  end

  def self.where *_
  end
end
