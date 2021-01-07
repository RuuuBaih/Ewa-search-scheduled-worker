# frozen_string_literal: false

module Ewa
  # Provides access to restuarant reviews
  module Restaurant
    # Data Mapper: Mapping review data into
    class ReviewMapper
      # build Review Entity
      class BuildReviewEntity
        def initialize(data)
          @array_of_hashes = data
        end

        def build_entity
          @array_of_hashes.map do |hash|
            hash.transform_keys(&:to_sym)
            DataMapper.new(hash).build_entity
          end
        end
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          Ewa::Entity::Review.new(
            id: nil,
            author_name: name,
            profile_photo_url: url,
            relative_time_description: time,
            text: text,
            rating: rating
          )
        end

        private

        def name
          @data['author_name']
        end

        def url
          @data['profile_photo_url']
        end

        def time
          @data['relative_time_description']
        end

        def text
          @data['text']
        end

        def rating
          @data['rating'].to_f
        end
      end
    end
  end
end
