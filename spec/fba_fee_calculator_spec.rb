require 'spec_helper'

# SPECS_AND_FEES = [
#   {
#     ASIN: "B00TEP32ES",
#     price: 10,
#     category: "Health & Personal Care",
#     weight: .3,
#     dimensions: [6.9, 5.1, 1.2],
#     fee: 4.19
#   },
#   {
#     ASIN: "B007T3Y2SW",
#     price: 10,
#     category: "Kitchen",
#     weight: .02,
#     dimensions: [6.3, 4, 3.5],
#     fee: 4.20
#   },
#   {
#     ASIN: "B00KWFCSB2",
#     price: 10,
#     category: "Video Games",
#     weight: .5,
#     dimensions: [7.6, 5.5, .8],
#     fee: 4.53
#   },
#   {
#     ASIN: "B00NNU07RU",
#     price: 100,
#     category: "Video Game Consoles",
#     weight: 9.7,
#     dimensions: [12.1, 11.5, 7.3],
#     fee: 14.95
#   },
#   {
#     ASIN: 1612184146,
#     price: 60,
#     category: "Books",
#     weight: 16.8,
#     dimensions: [9.69, 8.66, 6.69],
#     fee: 18.64
#   },
#   {
#     ASIN: "B00J44L7LY",
#     price: 10,
#     category: "Beauty",
#     weight: .02,
#     dimensions: [4.8, .9, .8],
#     fee: 4.17
#   },
#   {
#     ASIN: "B001BLX9DM",
#     price: 7,
#     category: "Office Products",
#     weight: 1.85,
#     dimensions: [11.9, 4.2, 2.2],
#     fee: 4.72
#   },
#   {
#     ASIN: "B00AB5QISC",
#     price: 6,
#     category: "Industrial & Scientific (including Food Service and Janitorial & Sanitation)",
#     weight: .05,
#     dimensions: [1.5, 1.5, .3],
#     fee: 3.54
#   },
#   {
#     ASIN: "B004INFQH2",
#     price: 3.74,
#     category: "Office Products",
#     weight: .05,
#     dimensions: ["0.40", "5.20", "3.10"],
#     fee: 3.54
#   }
# ]

describe FbaFeeCalculator do
  it "should require valid arguments" do
    fees = FbaFeeCalculator.calculate(
      price: -1.50,
      category: "Does not exist",
      weight: -1,
      dimensions: ["a", -10]
    )
    expect(fees.errors.full_messages.sort).to eq([
      "Price must be greater than 0",
      "Category is not included in the list",
      "Weight must be greater than 0",
      "Dimensions must have 3 parts (width, height, depth)",
      "Dimensions must contain all positive, numeric values"
    ].sort)
  end

  it "should accurately calculate fees (B0146667AK)" do
    fees = FbaFeeCalculator.calculate(
      price: 29.99,
      category: "Outdoors",
      weight: 1.3, # lbs
      dimensions: [4.3, 5.7, 8.3] # inches
    )
    expect(fees.revenue_subtotal).to eq(29.99)
    expect(fees.amazon_referral_fee).to eq(4.50)
    expect(fees.variable_closing_fee).to eq(0.00)
    expect(fees.order_handling).to eq(1.00)
    expect(fees.pick_and_pack).to eq(1.06)
    # expect(fees.weight_handling).to eq(1.95)
    expect(fees.monthly_storage).to eq(0.06)
    expect(fees.fulfillment_cost_subtotal).to eq(4.07)
    expect(fees.cost_subtotal).to eq(-8.57)
    expect(fees.margin_impact).to eq(21.42)
  end
end
