# frozen_string_literal: false

module Ewa
  # Provides access to restuarant pictures
  module Restaurant
    # Data Mapper: Mapping pictures data
    class PictureMapper
      def initialize(token, photos, gateway_class = Gmap::PlacePhotoApi)
        @token = token
        @photos = photos # array of hashes
        @gateway_class = gateway_class
      end

      # get pictures about restaurant
      def photo_lists
        photo_infos = photo_details
        if photo_infos != []
          photo_infos.map do |photo_info|
            thumb = photo_info['thumb']
            {
              link: @gateway_class.new(@token, photo_info['photo_reference'], thumb).place_photo,
              thumb: thumb
            }
          end
        else photo_infos end
      end

      # get photo details
      def photo_details
        if @photos.length < 5 then []
        else
          @photos.map.with_index do |photo, idx|
            photo['thumb'] = if (idx >= 0) && (idx <= 3) then true
                             else false                  end
          end
          @photos
        end
      end

      # build Picture Entity
      class BuildPictureEntity
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
          Ewa::Entity::Picture.new(
            id: nil,
            link: link,
            thumb: thumb
          )
        end

        private

        def link
          @data[:link]
        end

        def thumb
          @data[:thumb]
        end
      end
    end
  end
end
