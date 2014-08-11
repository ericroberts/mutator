module Mutator
  module Helpers
    def machine
      @machine ||= machine_class.new(self)
    end

    def self.included(base)
      "Mutator::#{base.name}".constantize.states.each do |state|
        base.send(:define_singleton_method, state) do
          self.where(state: state)
        end
      end
    end

  protected

    def machine_class
      "Mutator::#{self.class.name}".constantize
    end
  end
end
