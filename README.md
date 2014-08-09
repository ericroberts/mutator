# Mutator

Ya, this is another state machine gem. Why? Well, among the major state machine gems I found, they didn't quite do what I was looking for. So I wrote my own. Plus, reinventing the wheel is fun!

## Installation

Add this line to your application's Gemfile:

    gem 'mutator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mutator

## Usage

### So how does this thing work?

Well, I'm going to assume you are adding a state machine to a Rails ActiveRecord class. It can be used for other things but I figure this is the most common example and I don't like writing more documentation than I have to.

``` ruby
class Wonder < ActiveRecord::Base
  include Mutator::Helpers

  def state
    super || :signed # Set the default state. Can also be done in the database.
  end
end

module Mutator
  class Wonder < Machine
    def self.transitions
      [
        { to: :sealed, from: [:signed] },
        { to: :delivered, from: [:sealed] },
        { to: :yours, from: [:delivered] }
      ]
    end
  end
end
```

### So how do I use it?

Transition looks like this:

``` ruby
wonder = Wonder.new
wonder.machine.transition to: :sealed   #=> true

# Invalid Transition
wonder.machine.current_state            #=> :sealed
wonder.machine.transition to: :yours    #=> false
```

### How do I make it do things on success or failure?

Good question. Most state machines have you define callbacks. I wanted to do this one a bit differently. Whenever you call a transition, you are able to tell it what to do on success and failure. You do this like so:

``` ruby
wonder.machine.current_state            #=> :sealed

success = lambda { |t| puts "delivered!" }
failure = lambda { |t| puts "failed :(" }

wonder.machine.transition to: :delivered,
                          success: success,
                          failure: failure

                          #=> "delivered!"
                          #=> true

# Invalid Transition
wonder.machine.transition to: :yours,
                          success: success,
                          failure: failure

                          #=> "failed :("
                          #=> false
```

The lambdas will be called and passed the transition object. The transition object contains the state you are transitioning to, the state you are transitioning from, the machine, and the stateholder.

### OK, but what if I really want to do the same thing on every transition?

I bet back at the part where I defined `Mutator::Wonder`, you were thinking, "why the hell would you define a whole other class just to define your transitions?". I could have just always included an instance of Machine instead of the subclassed version.

This is a thing I'm still debating. The idea for keeping them separate is that it gives you a place for more state related behaviour to go. For example, to answer the question at the top of this heading, you could define a method to run the transition:

``` ruby
module Mutator
  class Wonder < Machine
    [...]

    # Save the activerecord class on success and raise exception on fail.
    def deliver!
      success = lambda { |t| t.stateholder.save! }
      failure = lambda { |t| fail "Cannot transition to #{t.to} from #{t.from}" }
      transition to: :delivered, success: success, failure: failure
    end
  end
end
```

Now you can always use `machine.deliver!` to do the transition to delivered.

### That's all folks!

That's more or less it. You may or may not like the way I've done this state machine, but it works for the purposes I need it for. I'm happy to discuss changes or reasoning behind certain things. There isn't a ton of code so feel free to poke around!

## Contributing

If your change is not just about fixing bugs, I would suggest opening an issue first. I think there are still improvements to be made, but I don't feel like making this a kitchen sink for behaviours provided by other state machines. If you think something should be added, an issue is the best way to let me know and we can discuss if functionality will be added to or changed.

That said, I'm pretty open to changing it, so let me know your thoughts!

Standard contributing instructions: (I have no idea if this is useful... I just always leave it here)

1. Fork it ( https://github.com/ericroberts/mutator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
