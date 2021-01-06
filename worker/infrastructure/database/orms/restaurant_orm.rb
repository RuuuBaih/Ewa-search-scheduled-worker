# frozen_string_literal: true

require 'sequel'

module Ewa
  module Database
    # Object Relational Mapper for Project Entities
    class RestaurantOrm < Sequel::Model(:restaurants)
      one_to_one :articles,
                 class: :'Ewa::Database::ArticleOrm'

      one_to_many :reviews,
                  class: :'Ewa::Database::ReviewOrm'

      one_to_many :pictures,
                  class: :'Ewa::Database::PictureOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end
