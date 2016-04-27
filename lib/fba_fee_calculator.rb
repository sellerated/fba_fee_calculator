require "fba_fee_calculator/fee_categories"
require "fba_fee_calculator/fba_fees"
require "fba_fee_calculator/version"

module FbaFeeCalculator
  def self.calculate(args)
    fba_fees = FbaFees.new

    fba_fees.price      = args[:price]
    fba_fees.category   = args[:category]
    fba_fees.weight     = args[:weight]
    fba_fees.dimensions = args[:dimensions]

    fba_fees.calculate!
    fba_fees
  end
end
