# frozen_string_literal: true

require 'sequel'

module Ewa
  # Database
  module Database
    # Object Relational Mapper for Picture
    class PictureOrm < Sequel::Model(:pictures)
      many_to_one :restaurant,
                  class: :'Ewa::Database::RestaurantOrm'

      plugin :timestamps, update_on_create: true
    end

    def self.find_or_create(picture_info)
      first(id: picture_info[:id]) || create(picture_info)
    end
  end
end
