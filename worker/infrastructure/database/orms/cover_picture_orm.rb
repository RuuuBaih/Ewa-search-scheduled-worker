# frozen_string_literal: true

require 'sequel'

module Ewa
  module Database
    # Object-Relational Mapper for Articles
    class CoverPictureOrm < Sequel::Model(:cover_pictures)
      many_to_one :restaurant,
                  class: :'Ewa::Database::RestaurantOrm'

      plugin :timestamps, update_on_create: true

      def self.find_or_create(cover_picture_info)
        first(id: cover_picture_info[:id]) || create(cover_picture_info)
      end
    end
  end
end
