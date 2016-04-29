require "fba_fee_calculator/fee_constants"
require "fba_fee_calculator/fba_fees"
require "fba_fee_calculator/fba_fee_calculation"
require "fba_fee_calculator/version"

module FbaFeeCalculator
  def self.calculate(args)
    price      = args[:price]
    category   = args[:category]
    weight     = args[:weight]
    dimensions = args[:dimensions]

    calculation = FbaFeeCalculation.new(price, category, weight, dimensions)
    calculation.calculate!
    calculation
  end
end
