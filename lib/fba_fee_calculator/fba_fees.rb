require "active_model"

module FbaFeeCalculator
  class FbaFees
    include ::ActiveModel::Model
    include FeeCategories

    attr_accessor :price, :category, :weight, :dimensions, :revenue_subtotal,
                  :amazon_referral_fee, :variable_closing_fee, :order_handling,
                  :pick_and_pack, :weight_handling, :monthly_storage,
                  :fulfillment_cost_subtotal, :cost_subtotal, :margin_impact,
                  :size

    validates :price, numericality: { greater_than: 0 }
    validates :category, inclusion: { in: PERCENTAGE_FEES.keys }
    validates :weight, numericality: { greater_than: 0 }
    validate :valid_dimensions

    CONSTRAINTS = {
      inbound_shipping_per_pound: 0.50,
      max_large_standard_weight: 20,
      max_large_standard_dimensions: [18, 14, 8],
      max_small_standard_media_weight: 0.875,
      max_small_standard_non_media_weight: 0.75,
      max_small_standard_dimensions: [15, 12, 0.75],
      max_small_oversize_weight: 70,
      max_small_oversize_dimensions: [60, 30]
    }

    def calculate!
      return unless valid?

      calculate_size
      calculate_revenue_subtotal
      calculate_amazon_referral_fee
      calulate_variable_closing_fee
      calculate_order_handling
      calculate_pick_and_pack
      calculate_weight_handling
      calculate_monthly_storage
      calculate_fulfillment_cost_subtotal
      calculate_cost_subtotal
      calculate_margin_impact
    end

    private

    def is_media?
      VARIABLE_CLOSING_FEES.keys.include? @category
    end

    def calculate_revenue_subtotal
      @revenue_subtotal = @price
    end

    def calculate_amazon_referral_fee
      puts PERCENTAGE_FEES.inspect
      pct_fee = (PERCENTAGE_FEES[@category].to_f / 100) * @price
      pct_fee = (pct_fee * 100).ceil.to_f / 100
      min_fee = MINIMUM_FEES[@category].to_f
      @amazon_referral_fee = [pct_fee, min_fee].max
    end

    def calulate_variable_closing_fee
      @variable_closing_fee = 0.00
      if is_media?
        @variable_closing_fee = VARIABLE_CLOSING_FEES[@category].to_f
      end
    end

    def calculate_order_handling
      @order_handling = 0.00
      if !is_media? && ["Small Standard", "Large Standard"].include?(@size)
        @order_handling = 1.00
      end
    end

    def calculate_pick_and_pack
      @pick_and_pack = 0.00
      if ["Small Standard", "Large Standard"].include? @size
        @pick_and_pack = 1.06
      elsif @size == "Small Oversize"
        @pick_and_pack = 4.05
      end
    end

    def calculate_weight_handling
      @weight_handling = 0.00

      puts "WEIGHT: #{@weight}"
      puts (@weight - 2).round * 0.39

      if @size == "Small Standard"
        @weight_handling = 0.50
      elsif @size == "Large Standard"
        if @weight < 1
          @weight_handling = 0.63
        elsif @weight < 2
          if is_media?
            @weight_handling = 0.88
          else
            @weight_handling = 1.59
          end
        else
          if is_media?
            @weight_handling = 0.88 + (@weight - 2).round * 0.41
          else
            @weight_handling = 1.59 + (@weight - 2).round * 0.39
          end
        end
      elsif @size == "Large Standard"
        @weight_handling = 1.59 + (@weight - 2).round * 0.39
      end
    end

    def calculate_monthly_storage
      @monthly_storage = 0.06
    end

    def calculate_fulfillment_cost_subtotal
      @fulfillment_cost_subtotal = 4.07
    end

    def calculate_cost_subtotal
      @cost_subtotal = -8.57
    end

    def calculate_margin_impact
      @margin_impact = 21.42
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

    # see https://www.amazon.com/gp/help/customer/display.html?nodeId=201119390
    def calculate_size
      @size = "Small Standard"

      # does it exceed the max dimensions for small?
      @dimensions.sort.reverse.each_with_index do |dimension, index|
        if (
          (dimension > CONSTRAINTS[:max_small_standard_dimensions][index]) ||
          (is_media? && @weight > CONSTRAINTS[:max_small_standard_media_weight]) ||
          (@weight > CONSTRAINTS[:max_small_standard_non_media_weight])
        )
          @size = "Large Standard"
        end
      end

      # if its not small, is it large?
      @dimensions.sort.reverse.each_with_index do |dimension, index|
        if (
          (dimension > CONSTRAINTS[:max_large_standard_dimensions][index]) ||
          (@weight > CONSTRAINTS[:max_large_standard_weight])
        )
          @size = "Small Oversize"
        end
      end
    end

  end
end
