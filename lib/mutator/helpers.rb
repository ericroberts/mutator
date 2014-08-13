module Mutator
  module Helpers
    def machine
      @machine ||= machine_class.new(self)
    end

    def self.included base
      Mutator.const_get(base.name, false).states.each do |state|
        base.send(:define_singleton_method, state) do
          self.where state: state
        end
      end
    end

  protected

    def machine_class
      Mutator.const_get self.class.name, false
    end
  end
end
