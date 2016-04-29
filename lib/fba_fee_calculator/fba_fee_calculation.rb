module FbaFeeCalculator
  class FbaFeeCalculation
    include ::ActiveModel::Model
    include ::FbaFeeCalculator::FeeConstants

    attr_reader :price, :category, :weight, :dimensions, :is_media, :size_category, :size_tier,
                :cubic_feet, :amazon_referral_fee, :variable_closing_fee, :order_handling, :packaging_weight,
                :pick_and_pack, :weight_handling, :monthly_storage, :revenue_subtotal, :outbound_shipping_weight,
                :fulfillment_cost_subtotal, :cost_subtotal, :margin_impact, :dimensional_weight

    validates :price, numericality: { greater_than: 0 }
    validates :category, inclusion: { in: PERCENTAGE_FEES.keys }
    validates :weight, numericality: { greater_than: 0 }
    validate :valid_dimensions

    def initialize(price, category, weight, dimensions)
      @price = price
      @category = category
      @weight = weight
      @dimensions = dimensions
      @fba_fees = FbaFees.new
    end

    def calculate!
      return unless valid?

      calculate_is_media
      calculate_size_category
      calculate_size_tier
      calculate_cubic_feet
      calculate_dimensional_weight
      calculate_packaging_weight
      calculate_outbound_shipping_weight
      calculate_revenue_subtotal
      calculate_amazon_referral_fee
      calculate_variable_closing_fee
      calculate_order_handling
      calculate_pick_and_pack
      calculate_weight_handling
      calculate_monthly_storage
      calculate_fulfillment_cost_subtotal
      calculate_cost_subtotal
      calculate_margin_impact

      self
    end

    private

    def calculate_is_media
      @is_media = @fba_fees.is_media?(category)
    end

    def calculate_size_category
      @size_category = @fba_fees.get_standard_or_oversize(dimensions, weight)
    end

    def calculate_size_tier
      @size_tier = @fba_fees.get_size_tier(size_category, weight, dimensions, is_media)
    end

    def calculate_cubic_feet
      @cubic_feet = @fba_fees.get_cubic_feet(dimensions)
    end

    def calculate_dimensional_weight
      @dimensional_weight = @fba_fees.get_dimensional_weight(dimensions)
    end

    def calculate_packaging_weight
      @packaging_weight = @fba_fees.get_packaging_weight(size_category, is_media)
    end

    def calculate_outbound_shipping_weight
      @outbound_shipping_weight =  @fba_fees.get_outbound_shipping_weight(size_tier, weight, packaging_weight, dimensional_weight)
    end

    def calculate_revenue_subtotal
      @revenue_subtotal = price
    end

    def calculate_amazon_referral_fee
      @amazon_referral_fee = @fba_fees.get_amazon_referral_fee(category, price)
    end

    def calculate_variable_closing_fee
      @variable_closing_fee = @fba_fees.get_variable_closing_fee(category, is_media)
    end

    def calculate_order_handling
      @order_handling = @fba_fees.get_order_handling(size_category, price)
    end

    def calculate_pick_and_pack
      @pick_and_pack = @fba_fees.get_pick_and_pack(size_tier)
    end

    def calculate_weight_handling
      @weight_handling = @fba_fees.get_weight_handling(size_tier, outbound_shipping_weight, is_media)
    end

    def calculate_monthly_storage
      @monthly_storage = @fba_fees.get_monthly_storage(size_category, cubic_feet)
    end

    def calculate_fulfillment_cost_subtotal
      @fulfillment_cost_subtotal = (@order_handling + @pick_and_pack + @weight_handling + @monthly_storage).round(2)
    end

    def calculate_cost_subtotal
      @cost_subtotal = ((@fulfillment_cost_subtotal + @amazon_referral_fee + @variable_closing_fee) * -1).round(2)
    end

    def calculate_margin_impact
      @margin_impact = (@price + @cost_subtotal).round(2)
    end

    def valid_dimensions
      errs = []
      if dimensions.length != 3
        errs << "must have 3 parts (width, height, depth)"
      end

      dimensions.each do |dimension|
        if dimension.to_f <= 0
          errs << "must contain all positive, numeric values"
        end
      end

      errs.uniq.each do |err|
        errors.add(:dimensions, err)
      end
    end
  end
end
