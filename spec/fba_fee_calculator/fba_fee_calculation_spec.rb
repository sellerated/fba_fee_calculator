require 'spec_helper'

describe FbaFeeCalculator::FbaFeeCalculation do
  subject { ::FbaFeeCalculator::FbaFeeCalculation.new(29.99, "Outdoors", 1.3, [4.3, 5.7, 8.3]) }

  it "should require valid arguments" do
    calc = ::FbaFeeCalculator::FbaFeeCalculation.new(-1.50, "Does not exist", -1, ["a", -10])
    calc.calculate!
    expect(calc.errors.full_messages.sort).to eq([
      "Price must be greater than 0",
      "Category is not included in the list",
      "Weight must be greater than 0",
      "Dimensions must have 3 parts (width, height, depth)",
      "Dimensions must contain all positive, numeric values"
    ].sort)
  end

end
