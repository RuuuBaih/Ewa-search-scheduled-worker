# frozen_string_literal: true

require 'sequel'

module Ewa
  # Database
  module Database
    # Object Relational Mapper for Review
    class ReviewOrm < Sequel::Model(:reviews)
      many_to_one :restaurant,
                  class: :'Ewa::Database::RestaurantOrm'

      plugin :timestamps, update_on_create: true
    end

    def self.find_or_create(review_info)
      first(id: review_info[:id]) || create(review_info)
    end
  end
end
