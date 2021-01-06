# frozen_string_literal: true

module Ewa
  module Value
    # Define Ewa tags
    class EwaTags
      def initialize(money, google_rating)
        @money = money
        @google_rating = google_rating
      end

      #       def ewa_tag_hash
      #         { restaurant_id: @id, ewa_tag: tag_rules }
      #       end

      def tag_rules
        if @money >= 1000 && @google_rating >= 4.5 then '老闆請客 Boss, please treat me!'
        elsif @money >= 1000 && @google_rating.between?(4, 4.5) then '存點錢再吃  Eat when you have budget!'
        elsif @money.between?(500, 1000) && @google_rating >= 4.5 then '女朋友叫你帶她去吃 Your girlfriend said she wants to eat that!'
        elsif @money.between?(500, 1000) && @google_rating.between?(4, 4.5) then '同學會可食 Eat this in your class reunion!'
        elsif @money.between?(300, 500) && @google_rating >= 4.5 then '發薪日可食 Eat when you get your salary!'
        elsif @money.between?(300, 500) && @google_rating.between?(4, 4.5) then '吃拉，哪次不吃~ Ok, just eat that.'
        elsif @money.between?(1, 300) && @google_rating >= 4.5 then '便宜上天堂 Go to heaven~'
        elsif @money.between?(1, 300) && @google_rating.between?(4, 4.5) then 'cp值爆高 Cheap and happy!'
        elsif @money.between?(1, 300) && @google_rating <= 3.5 then '維持生命 Only maintaining my life'
        elsif @money > 300 && @google_rating <= 3.5 then '痛苦盤子 Eat sh**!'
        elsif @money.zero? then '查無價格 No price'
        else
          '哎呀還行拉 So~so!'
        end
      end
    end
  end
end
