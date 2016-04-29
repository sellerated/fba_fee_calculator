require 'spec_helper'

describe FbaFeeCalculator::FbaFees do
  subject { FbaFeeCalculator::FbaFees.new }

  describe "#get_girth_and_length" do
    it "should return expected results" do
      expect(subject.get_girth_and_length([10, 15, 20])).to eq(70)
    end
  end

  describe "#get_standard_or_oversize" do
    it "should return correct size" do
      expect(subject.get_standard_or_oversize([1, 1, 1], 1)).to eq("Standard")
      expect(subject.get_standard_or_oversize([1, 1, 1], 21)).to eq("Oversize")
      expect(subject.get_standard_or_oversize([19, 1, 1], 1)).to eq("Oversize")
      expect(subject.get_standard_or_oversize([1, 19, 1], 1)).to eq("Oversize")
      expect(subject.get_standard_or_oversize([1, 1, 19], 1)).to eq("Oversize")
      expect(subject.get_standard_or_oversize([9, 10, 10], 1)).to eq("Oversize")
      expect(subject.get_standard_or_oversize([10, 9, 10], 1)).to eq("Oversize")
      expect(subject.get_standard_or_oversize([10, 10, 9], 1)).to eq("Oversize")
      expect(subject.get_standard_or_oversize([1, 15, 19], 1)).to eq("Oversize")
    end
  end

  describe "#get_dimensional_weight" do
    it "should return expected results" do
      expect(subject.get_dimensional_weight([20, 20, 20])).to eq(48.19)
    end
  end

  describe "#get_cubic_feet" do
    it "should return expected results" do
      expect(subject.get_cubic_feet([20, 20, 20])).to eq(4.63)
      expect(subject.get_cubic_feet([9, 25, 6])).to eq(0.781)
    end
  end

  describe "#get_monthly_storage" do
    it "should return expected result for March" do
      Timecop.freeze(Date.parse("2016-03-12").to_time)
      expect(subject.get_monthly_storage("Standard", 0.118)).to eq(0.06)
      expect(subject.get_monthly_storage("Oversize", 0.118)).to eq(0.05)
      Timecop.return
    end

    it "should return expected result for November" do
      Timecop.freeze(Date.parse("2016-11-12").to_time)
      expect(subject.get_monthly_storage("Standard", 0.118)).to eq(0.08)
      expect(subject.get_monthly_storage("Oversize", 0.118)).to eq(0.07)
      Timecop.return
    end
  end

  describe "#get_order_handling" do
    it "should return expected results" do
      expect(subject.get_order_handling("Standard", 29.99)).to eq(1)
      expect(subject.get_order_handling("Oversize", 29.99)).to eq(0)
      expect(subject.get_order_handling("Standard", 29.99, true)).to eq(0)
      expect(subject.get_order_handling("Standard", 329.99)).to eq(0)
    end
  end

  describe "#get_weight_handling" do
    it "should return expected results" do
      expect(subject.get_weight_handling("SML_STND", 0.625)).to eq(0.5)
      expect(subject.get_weight_handling("LRG_STND", 0.625)).to eq(0.96)
      expect(subject.get_weight_handling("LRG_STND", 1.625, true)).to eq(1.24)
      expect(subject.get_weight_handling("LRG_STND", 2.625, true)).to eq(1.65)
      # expect(subject.get_weight_handling("LRG_STND", 1.5, 1.75)).to eq(1.59)
      # expect(subject.get_weight_handling("LRG_STND", 2.5, 2.75)).to eq(1.98)
      # expect(subject.get_weight_handling("SPL_OVER", 80)).to eq(124.58)
      # expect(subject.get_weight_handling("SPL_OVER", 100)).to eq(133.78)
      # expect(subject.get_weight_handling("LRG_OVER", 80)).to eq(63.09)
      # expect(subject.get_weight_handling("LRG_OVER", 150)).to eq(118.29)
      # expect(subject.get_weight_handling("MED_OVER", 1.5)).to eq(2.23)
      # expect(subject.get_weight_handling("MED_OVER", 2.5)).to eq(2.62)
      # expect(subject.get_weight_handling("Standard", 1.5)).to eq(1.59)
      # expect(subject.get_weight_handling("Standard", 2.5)).to eq(1.98)
      # expect(subject.get_weight_handling("SML_STND", 0.3)).to eq(1.98)
    end
  end

  describe "#get_amazon_referral_fee" do
    it "should return expected results" do
      expect(subject.get_amazon_referral_fee("Musical Instruments", 29.99)).to eq(4.5)
      expect(subject.get_amazon_referral_fee("Musical Instruments", 5.99)).to eq(1.0)
      expect(subject.get_amazon_referral_fee("Amazon Device Accessories", 29.99)).to eq(13.5)
      expect(subject.get_amazon_referral_fee("Amazon Device Accessories", 329.99)).to eq(148.5)
    end
  end

  describe "#get_variable_closing_fee" do
    it "should return expected results" do
      expect(subject.get_variable_closing_fee("Books")).to eq(0)
      expect(subject.get_variable_closing_fee("Books", true)).to eq(1.35)
      expect(subject.get_variable_closing_fee("Watches")).to eq(0)
      expect(subject.get_variable_closing_fee("Watches", true)).to eq(0)
    end
  end

  describe "#get_pick_and_pack" do
    it "should return expected results" do
      expect(subject.get_pick_and_pack("SML_STND")).to eq(1.06)
      expect(subject.get_pick_and_pack("LRG_STND")).to eq(1.06)
      expect(subject.get_pick_and_pack("SML_OVER")).to eq(4.09)
      expect(subject.get_pick_and_pack("MED_OVER")).to eq(5.20)
      expect(subject.get_pick_and_pack("LRG_OVER")).to eq(8.40)
      expect(subject.get_pick_and_pack("SPL_OVER")).to eq(10.53)
      expect(subject.get_pick_and_pack("NOTHING")).to eq(0.0)
    end
  end
end
