# frozen_string_literal: false

require_relative '../../restaurant_options/init'

module Ewa
  # Provides access to restuarant details data
  module Restaurant
    # Data Mapper: Gmap Place API & Place details API -> RestuarantDetail entity
    class RestaurantDetailMapper
      def initialize(
        restaurant_entity,
        gmap_token,
        gateway_classes = {
          gmap_place: Gmap::PlaceApi,
          gmap_place_details: Gmap::PlaceDetailsApi
        }
      )
        @poi_entity = restaurant_entity
        @token = gmap_token
        @gateway_classes = gateway_classes
      end

      # get google map place full details
      def gmap_place_details
        place_name = FoolProof.new(@poi_entity.name, @poi_entity.branch_store_name, @poi_entity.town).check_gmap_place_name
        gmap_place_gateway = @gateway_classes[:gmap_place].new(@token, place_name)
        place_id = gmap_place_gateway.place_id['candidates']
        if place_id.length.zero?
          # if google has no data return origin entity, then the details page won't show anything about google
          @poi_entity
        else
          place_hash = @gateway_classes[:gmap_place_details].new(@token, place_id[0]['place_id']).place_details['result']
          filtered_hash = FilterHash.new(@poi_entity, place_hash).filtered_gmap_details_hash

          BuildRestaurantDetailEntity.new(filtered_hash, @token).build_entity
        end
      end

      # try to avoid some situations
      class FoolProof
        def initialize(name, branch_store_name, town)
          @name = name
          @branch_store_name = branch_store_name
          @town = town
        end

        # try to search with restaurant name & branch store name or restaurant name & town
        # try to avoid getting results from the wrong branch store or town
        def check_gmap_place_name
          if @branch_name.to_s.length.zero?
            "#{@name}#{@town}".gsub(' ', '')
          else
            "#{@name}#{@branch_name}".gsub(' ', '')
          end
        end
      end

      # build RestaurantDetail Entity
      class BuildRestaurantDetailEntity
        def initialize(hash, token)
          @hash = hash
          @token = token
        end

        def build_entity
          DataMapper.new(@hash, @token).build_entity
        end
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, token)
          @data = data
          @token = token
        end

        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/AbcSize
        def build_entity
          Ewa::Entity::RestaurantDetail.new(
            id: @data['id'],
            name: @data['name'],
            branch_store_name: @data['branch_store_name'],
            town: @data['town'],
            city: @data['city'],
            open_hours: @data['open_hours'],
            telephone: @data['telephone'],
            cover_img: @data['cover_img'],
            tags: @data['tags'],
            money: @data['money'],
            pixnet_rating: @data['pixnet_rating'].to_f,
            google_rating: @data['google_rating'].to_f,
            address: @data['address'],
            website: @data['website'],
            cover_pictures: @data['cover_pictures'],
            reviews: reviews,
            pictures: pictures,
            article: article,
            ewa_tag: ewa_tag,
            clicks: @data['clicks'],
            likes: @data['likes']
          )
        end
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/AbcSize

        private

        def reviews
          review_hashes = @data['reviews']
          if review_hashes.nil? then nil
          else ReviewMapper::BuildReviewEntity.new(review_hashes).build_entity end
        end

        def article
          article = ArticleMapper.new(@data['name']).the_newest_article
          ArticleMapper::BuildArticleEntity.new(article).build_entity
        end

        def pictures
          photo_hashes = @data['pictures']
          if photo_hashes.nil? then nil
          else
            photos = PictureMapper.new(@token, photo_hashes).photo_lists
            PictureMapper::BuildPictureEntity.new(photos).build_entity
          end
        end

        def ewa_tag
          ewa_tag_hash = RestaurantPickMapper.new(@data).ewa_tag
          RestaurantPickMapper::BuildEwaTagEntity.new(ewa_tag_hash).build_entity
        end
      end
    end

    # Use to filter hashes
    class FilterHash
      def initialize(poi_entity, hash)
        @poi_entity = poi_entity
        @hash = hash
        @new_hash = {}
      end

      def filtered_gmap_details_hash
        @new_hash = {
          'id' => @poi_entity.id,
          'name' => @poi_entity.name,
          'branch_store_name' => @poi_entity.branch_store_name,
          'town' => @poi_entity.town,
          'city' => @poi_entity.city,
          'money' => @poi_entity.money,
          'telephone' => @poi_entity.telephone,
          'cover_img' => @poi_entity.cover_img,
          'tags' => @poi_entity.tags,
          'pixnet_rating' => @poi_entity.pixnet_rating,
          'google_rating' => @hash['rating'],
          'cover_pictures' => @poi_entity.cover_pictures,
          # clicks add 1 if the restaurant image is clicked
          'clicks' => (@poi_entity.clicks.to_i + 1),
          'likes' => @poi_entity.likes,
          'reviews' => reviews,
          'pictures' => photos
        }
        filter_details
        @new_hash
      end

      private

      def filter_details
        @new_hash['address'] = @hash.key?('formatted_address') ? @hash['formatted_address'] : @poi_entity.address
        @new_hash['website'] = @hash.key?('website') ? @hash['website'] : @poi_entity.website
        @new_hash['open_hours'] = @hash.key?('opening_hours') ? @hash['opening_hours']['weekday_text'] : @poi_entity.open_hours
      end

      # filter the gmap place reviews fields, select what we want
      def reviews
        if !@hash.key?('reviews') then nil
        else
          @hash['reviews'].reduce([]) do |start, hash|
            review_hash = hash.select do |key, _value|
              key_lists = %w[author_name profile_photo_url rating text relative_time_description]
              key_lists.include? key
            end
            start << review_hash
          end
        end
      end

      # filter the gmap place photos fields, select what we want
      def photos
        if !@hash.key?('photos') then nil
        else
          @hash['photos'].reduce([]) do |start, hash|
            photo_hash = hash.select do |key, _value|
              key_lists = %w[photo_reference]
              key_lists.include? key
            end
            start << photo_hash
          end
        end
      end
    end
  end
end
