# frozen_string_literal: true

module Ewa
  module Restaurant
    # Get filtered restaurant_pick
    class RestaurantPickMapper
      def initialize(rest_hash)
        @rest_pick = rest_hash
      end

      def ewa_tag
        Entity::RestaurantPick.new(@rest_pick).ewa_tag_hash
      end

      # build ewa tag entity
      class BuildEwaTagEntity
        def initialize(ewa_tag_text)
          @ewa_tag_text = ewa_tag_text
        end

        def build_entity
          Entity::EwaTag.new(
            id: nil,
            ewa_tag: @ewa_tag_text
          )
        end
      end
    end
  end
end
