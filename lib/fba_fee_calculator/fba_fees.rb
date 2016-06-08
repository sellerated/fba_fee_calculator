require "active_model"

module FbaFeeCalculator
  class FbaFees
    include ::FbaFeeCalculator::FeeConstants

    def is_media?(category)
      VARIABLE_CLOSING_FEES.keys.include? category
    end

    # https://www.amazon.com/gp/help/customer/display.html?nodeId=201119390
    def get_size_tier(size_category, weight, dimensions, is_media = false)
      if size_category == "Standard"
        fee_weight = is_media ? (14.to_f / 16.to_f) : (12.to_f / 16.to_f)
        if [ (fee_weight > weight),
             (dimensions.max <= 15),
             (dimensions.min <= 0.75),
             (median(dimensions) <= 12) ].all?
          return "SML_STND"
        else
          return "LRG_STND"
        end
      else
        girth_length = get_girth_and_length(dimensions)
        if [ (girth_length > 165),
             (weight > 150),
             (dimensions.max > 108) ].any?
          return "SPL_OVER"
        elsif girth_length > 130
          return "LRG_OVER"
        elsif [ (weight > 70),
                (dimensions.max > 60),
                (median(dimensions) <= 30) ].any?
          return "MED_OVER"
        else
          return "SML_OVER"
        end
      end
    end

    def get_pick_and_pack(size_tier)
      return 0 unless PICK_PACK.keys.include?(size_tier)
      PICK_PACK[size_tier]
    end

    def get_variable_closing_fee(category, is_media = false)
      return VARIABLE_CLOSING_FEES[category].to_f if is_media
      0.0
    end

    def get_amazon_referral_fee(category, price)
      pct_fee = (PERCENTAGE_FEES[category].to_f / 100) * price
      pct_fee = (pct_fee * 100).ceil.to_f / 100
      min_fee = MINIMUM_FEES[category].to_f
      [pct_fee, min_fee].max
    end

    def get_outbound_shipping_weight(size_tier, weight, packaging_weight, dimensional_weight)
      if ["SML_STND", "LRG_STND"].include? size_tier
        if weight <= 1
          return weight + packaging_weight
        else
          return [weight, dimensional_weight].max + packaging_weight
        end
      elsif size_tier == "SPL_OVER"
        return weight + packaging_weight
      else
        return [weight, dimensional_weight].max + packaging_weight
      end
    end

    def get_weight_handling(size_tier, outbound_shipping_weight, is_media = false)
      weight = outbound_shipping_weight.ceil

      case size_tier
        when "SML_STND"
          return 0.5
        when "LRG_STND"
          if is_media
            return 0.85 if weight <= 1
            return 1.24 if weight <= 2
            return 1.24 + (weight - 2) * 0.41
          else
            return 0.96 if weight <= 1
            return 1.95 if weight <= 2
            return 1.95 + (weight - 2) * 0.39
          end
        when "SML_OVER"
          return 2.06 if weight <= 2
          return 2.06 + (weight - 2) * 0.39
        when "MED_OVER"
          return 2.73 if weight <= 2
          return 2.73 + (weight - 2) * 0.39
        when "LRG_OVER"
          return 63.98 if weight <= 90
          return 63.98 + (weight - 90) * 0.80
        when "SPL_OVER"
          return 124.58 if weight <= 90
          return 124.58 + (weight - 90) * 0.92
      end
    end

    # https://www.amazon.com/gp/help/customer/display.html/?nodeId=201119410
    def get_order_handling(size_category, price, is_media = false)
      if !is_media && size_category == "Standard" && price < 300
        return 1
      end
      return 0
    end

    # January - September
    #   Standard - $0.54 per cubic foot
    #   Oversize - $0.43 per cubic foot
    # October - December
    #   Standard - $0.72 per cubic foot
    #   Oversize - $0.57 per cubic foot
    #
    # See http://www.amazon.com/gp/help/customer/display.html?nodeId=200627230
    def get_monthly_storage(size_category, cubic_feet)
      monthly_storage = 0
      current_month = Time.now.utc.month

      if current_month <= 9
        if size_category == "Standard"
          monthly_storage = 0.54 * cubic_feet
        else
          monthly_storage = 0.43 * cubic_feet
        end
      else
        if size_category == "Standard"
          monthly_storage = 0.72 * cubic_feet
        else
          monthly_storage = 0.57 * cubic_feet
        end
      end

      monthly_storage.round(2)
    end

    # http://www.amazon.com/gp/help/customer/display.html?nodeId=201119390
    def get_girth_and_length(dimensions)
      (dimensions.max + (median(dimensions) * 2) + (dimensions.min * 2)).round(1)
    end

    # https://www.amazon.com/gp/help/customer/display.html?nodeId=201119390
    def get_standard_or_oversize(dimensions, weight)
      if [ (weight > 20),
           (dimensions.max > 18),
           (dimensions.min > 8),
           (median(dimensions) > 14) ].any?
        "Oversize"
      else
        "Standard"
      end
    end

    def get_dimensional_weight(dimensions)
      (dimensions.inject(:*).to_f / 166).round(2)
    end

    def get_cubic_feet(dimensions)
      (dimensions.inject(:*).to_f / 1728).round(3)
    end

    # http://www.amazon.com/gp/help/customer/display.html/?nodeId=201119410#calc
    def get_packaging_weight(size_category, is_media)
      return 0.125 if is_media
      if size_category == "Standard"
        return 0.25
      else
        return 1.0
      end
    end

    private

    def median(array)
      sorted = array.sort
      len = sorted.length
      (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
    end

  end
end
