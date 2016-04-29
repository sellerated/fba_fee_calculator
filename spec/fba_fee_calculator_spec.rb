require 'spec_helper'

describe FbaFeeCalculator do
  it "should accurately calculate fees (B0146667AK)" do
    subject = FbaFeeCalculator.calculate(
      price: 29.99,
      category: "Outdoors",
      weight: 1.3, # lbs
      dimensions: [4.3, 5.7, 8.3] # inches
    )

    expect(subject.size_category).to eq("Standard")
    expect(subject.size_tier).to eq("LRG_STND")
    expect(subject.revenue_subtotal).to eq(29.99)
    expect(subject.amazon_referral_fee).to eq(4.50)
    expect(subject.variable_closing_fee).to eq(0.00)
    expect(subject.order_handling).to eq(1.00)
    expect(subject.pick_and_pack).to eq(1.06)
    expect(subject.weight_handling).to eq(1.95)
    expect(subject.monthly_storage).to eq(0.06)
    expect(subject.fulfillment_cost_subtotal).to eq(4.07)
    expect(subject.cost_subtotal).to eq(-8.57)
    expect(subject.margin_impact).to eq(21.42)
  end

  it "should accurately calculate fees (B00TEP32ES)" do
    subject = FbaFeeCalculator.calculate(
      price: 10.00,
      category: "Health & Personal Care",
      weight: 0.3, # lbs
      dimensions: [6.9, 5.1, 1.2] # inches
    )

    expect(subject.size_category).to eq("Standard")
    expect(subject.size_tier).to eq("LRG_STND")
    expect(subject.revenue_subtotal).to eq(10.00)
    expect(subject.amazon_referral_fee).to eq(1.50)
    expect(subject.variable_closing_fee).to eq(0.00)
    expect(subject.order_handling).to eq(1.00)
    expect(subject.pick_and_pack).to eq(1.06)
    expect(subject.weight_handling).to eq(0.96)
    expect(subject.monthly_storage).to eq(0.01)
    expect(subject.fulfillment_cost_subtotal).to eq(3.03)
    expect(subject.cost_subtotal).to eq(-4.53)
    expect(subject.margin_impact).to eq(5.47)
  end

  it "should accurately calculate fees (B007T3Y2SW)" do
    subject = FbaFeeCalculator.calculate(
      price: 10.00,
      category: "Kitchen",
      weight: 0.02, # lbs
      dimensions: [6.3, 4, 3.5] # inches
    )

    expect(subject.size_category).to eq("Standard")
    expect(subject.size_tier).to eq("LRG_STND")
    expect(subject.revenue_subtotal).to eq(10.00)
    expect(subject.amazon_referral_fee).to eq(1.50)
    expect(subject.variable_closing_fee).to eq(0.00)
    expect(subject.order_handling).to eq(1.00)
    expect(subject.pick_and_pack).to eq(1.06)
    expect(subject.weight_handling).to eq(0.96)
    expect(subject.monthly_storage).to eq(0.03)
    expect(subject.fulfillment_cost_subtotal).to eq(3.05)
    expect(subject.cost_subtotal).to eq(-4.55)
    expect(subject.margin_impact).to eq(5.45)
  end

  it "should accurately calculate fees (B007T3Y2SW)" do
    subject = FbaFeeCalculator.calculate(
      price: 6.00,
      category: "Industrial & Scientific (including Food Service and Janitorial & Sanitation)",
      weight: 0.05, # lbs
      dimensions: [1.5, 1.5, 0.3] # inches
    )

    expect(subject.size_category).to eq("Standard")
    expect(subject.size_tier).to eq("SML_STND")
    expect(subject.revenue_subtotal).to eq(6.00)
    expect(subject.amazon_referral_fee).to eq(1.00)
    expect(subject.variable_closing_fee).to eq(0.00)
    expect(subject.order_handling).to eq(1.00)
    expect(subject.pick_and_pack).to eq(1.06)
    expect(subject.weight_handling).to eq(0.50)
    expect(subject.monthly_storage).to eq(0.00)
    expect(subject.fulfillment_cost_subtotal).to eq(2.56)
    expect(subject.cost_subtotal).to eq(-3.56)
    expect(subject.margin_impact).to eq(2.44)
  end
end
