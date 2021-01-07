# frozen_string_literal: true

module Ewa
  module Restaurant
    # Get filtered restaurant_repo_entites
    class RestaurantOptionsMapper
      def initialize(selected_entities, random_num, page, per_page)
        @selected_entities = selected_entities
        @random_num = random_num
        @page = page
        @per_page = per_page
      end

      # Get random repository entities of restaurants
      def random_picks
        if @selected_entities.length.zero?
          raise StandardError
        elsif @random_num.zero?
          @selected_entities.each_slice(@per_page).to_a[@page - 1]
        else
          @selected_entities.sample(@random_num)
        end
      end

      # Get total numbers 
      def total
        if @selected_entities.length.zero?
          raise StandardError
        else
          @selected_entities.count 
        end
      end
    end
  end
end
