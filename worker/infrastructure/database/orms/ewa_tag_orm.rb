# frozen_string_literal: true

require 'sequel'

module Ewa
  module Database
    # Object-Relational Mapper for EwaTags
    class EwaTagOrm < Sequel::Model(:ewa_tags)
      one_to_one :restaurant,
                 class: :'Ewa::Database::RestaurantOrm'

      plugin :timestamps, update_on_create: true

      def self.find_or_create(tag_info)
        first(restaurant_id: tag_info[:restaurant_id]) || create(tag_info)
      end
    end
  end
end
