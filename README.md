# WeightedList [![Build Status](https://travis-ci.org/jaysonvirissimo/weighted_list.svg?branch=master)](https://travis-ci.org/jaysonvirissimo/weighted_list)

**WeightedList** attempts to improve on the very popular [weighted_randomizer](https://rubygems.org/gems/weighted_randomizer) gem, by:

1. Sampling *without* replacement, analogous to Ruby's own `Array#sample`

2. Behaving as a typical Ruby collection with `#each`, `#map`, `#sort`, etc...

3. Using any user supplied randomizer that responds to `#rand` with a number

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'weighted_list'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install weighted_list

## Usage
```ruby
list = WeightedList.new({ eastern: 150, central: 92, mountain: 21, pacific: 53 })

list.sample # => :pacific
list.sample(1) # => [:central]
list.sample(3) # => [:central, :eastern, :pacific]
list.sample(100) # => [:central, :eastern, :pacific, :mountain]

list.map(&:to_s).map(&:capitalize).sort.join(', ') # => "Central, Eastern, Mountain, Pacific"

class CustomRandomizer
  def rand(n)
    1.0
  end
end
list.sample(2, random: CustomRandomizer.new) # => [:eastern, :central]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jaysonvirissimo/weighted_list.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
