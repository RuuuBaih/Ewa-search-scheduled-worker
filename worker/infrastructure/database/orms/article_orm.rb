# frozen_string_literal: true

require 'sequel'

module Ewa
  module Database
    # Object-Relational Mapper for Articles
    class ArticleOrm < Sequel::Model(:articles)
      one_to_one :restaurant,
                 class: :'Ewa::Database::RestaurantOrm'

      plugin :timestamps, update_on_create: true

      def self.find_or_create(article_info)
        first(link: article_info[:link], restaurant_id: article_info[:restaurant_id]) || create(article_info)
      end
    end
  end
end
