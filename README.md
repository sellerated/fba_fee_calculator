# FBA Fee Calculator

[![Gem Version](https://badge.fury.io/rb/fba_fee_calculator.svg)](https://badge.fury.io/rb/fba_fee_calculator)

This gem provides most of the information provided by Amazon's [FBA Profitability Calculator](https://sellercentral.amazon.com/hz/fba/profitabilitycalculator/index)

Inspired by [hamptus](https://github.com/hamptus/fbacalculator)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fba_fee_calculator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fba_fee_calculator

## Usage

```ruby
results = FbaFeeCalculator.calculate(
  price: 29.99,
  category: "Outdoors",
  weight: 1.3, # lbs
  dimensions: [4.3, 5.7, 8.3] # inches
)

results.size_category             # => "Standard"
results.size_tier                 # => "LRG_STND"
results.revenue_subtotal          # => 29.99
results.amazon_referral_fee       # => 4.50
results.variable_closing_fee      # => 0.00
results.order_handling            # => 1.00
results.pick_and_pack             # => 1.06
results.weight_handling           # => 1.95
results.monthly_storage           # => 0.06
results.fulfillment_cost_subtotal # => 4.07
results.cost_subtotal             # => -8.57
results.margin_impact             # => 21.42
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sellerated/fba_fee_calculator.

