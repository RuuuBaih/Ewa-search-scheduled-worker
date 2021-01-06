# frozen_string_literal: true

module Ewa
  module Entity
    # Aggregate root for contributions domain
    class RestaurantPick
      def initialize(rest_hash)
        @rest_pick = rest_hash
      end

      def ewa_tag_hash
        # hope to return a ewa tag hash back
        # (e.g. {"restaurant_id": id, "ewa_tag": ewa_tag})
        Value::EwaTags.new(
          @rest_pick['money'],
          @rest_pick['google_rating']
        ).tag_rules
      end
    end
  end
end
