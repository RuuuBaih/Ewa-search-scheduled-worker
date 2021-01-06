# frozen_string_literal: false

module Ewa
  # Provides access to restuarant cover pictures
  module Restaurant
    # Data Mapper: Mapping cover pictures data
    class CoverPictureMapper
      def initialize(custom_search_token, custom_search_cx, name, gateway_class = CustomSearch::CustomSearchApi)
        @token = custom_search_token # custom search api key
        @cx = custom_search_cx # custom search engine setting key
        @name = name # restaurant_name
        @gateway_class = gateway_class
      end

      # get cover pictures about restaurant
      def cover_picture_lists
        name = "#{@name}料理"
        ret = @gateway_class.new(@token, name, @cx).search_photo
        if ret.key?('items')
          cover_pictures = ret['items']
          cover_pictures.map do |cover_picture|
            {
              picture_link: cover_picture['link'],
              article_link: cover_picture['image']['contextLink']
            }
          end
        else [] end
      end

      # build Picture Entity
      class BuildCoverPictureEntity
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
          Ewa::Entity::CoverPicture.new(
            id: nil,
            picture_link: picture_link,
            article_link: article_link
          )
        end

        private

        def picture_link
          @data[:picture_link]
        end

        def article_link
          @data[:article_link]
        end
      end
    end
  end
end
