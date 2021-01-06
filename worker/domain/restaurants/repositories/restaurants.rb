# frozen_string_literal: true

require 'json'

module Ewa
  module Repository
    # Repository for Restaurant Entities
    class Restaurants
      def self.all
        Database::RestaurantOrm.all.map { |db_restaurant| rebuild_entity(db_restaurant) }
      end

      def self.all_desc_order_by_clicks
        Database::RestaurantOrm.order(Sequel.desc(:clicks)).all.map { |db_restaurant| rebuild_entity(db_restaurant) }
      end

      def self.find(entity)
        Database::RestaurantOrm.first(name: entity.name, branch_store_name: entity.branch_store_name)
      end

      def self.find_by_town_money(town, min_money, max_money)
        # 15 should be erased in the future
        db_records = Database::RestaurantOrm.where(town: town, money: min_money...max_money).limit(15).all
        db_records.map do |db_record|
          rebuild_entity(db_record)
        end
      end

      def self.find_restaurant_id(entity)
        db_record = Database::RestaurantOrm.first(id: entity.id)
        rebuild_entity(db_record)
      end

      def rest_exist(entity)
        db_entity = find(entity)
        raise 'Related restaurant not found' unless db_entity
      end

      def self.update_reviews2db(db_entity)
        rest_exist(db_entity)

        entity_id = db_entity.id
        raise 'Already five reviews exist' if Reviews.find_all_reviews_by_restaurant_id(entity_id).length > 4

        Reviews.rebuild_many(PersistRestaurant.new(entity).put_reviews_to_db(entity_id))
      end

      def self.update_article2db(db_entity)
        rest_exist(db_entity)

        entity_id = db_entity.id
        raise 'Article exist' if Articles.find_article_by_restaurant_id(entity_id)

        Article.rebuild_entity(PersistRestaurant.new(entity).put_article_to_db(entity_id))
      end

      def self.update_pictures2db(db_entity)
        rest_exist(db_entity)

        entity_id = db_entity.id
        raise 'Already ten pictures exist' if Pictures.find_all_pics_by_restaurant_id(entity_id).length > 9

        Pictures.rebuild_many(PersistRestaurant.new(entity).put_pics_to_db(entity_id))
      end

      def self.update_ewa_tag2db(db_entity)
        rest_exist(db_entity)

        entity_id = db_entity.id
        raise 'Ewa tag exist' if EwaTags.find_ewa_tag_by_restaurant_id(entity_id)

        EwaTags.rebuild_entity(PersistRestaurant.new(entity).put_ewa_tag_to_db(entity_id))
      end

      def self.create(entity)
        db_entity = find(entity)
        return rebuild_entity(db_entity) if db_entity

        db_restaurant = PersistRestaurant.new(entity).call
        rebuild_entity(db_restaurant)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        db_record_id = db_record.id

        db_record[:tags] = JSON.parse(db_record[:tags])
        db_record[:open_hours] = JSON.parse(db_record[:open_hours])

        Entity::Restaurant.new(
          db_record.to_hash.merge(
            cover_pictures: CoverPictures.find_all_cover_pics_by_restaurant_id(db_record_id)
          )
        )
      end
      # make sure data goes to database also
      class PersistRestaurant
        def initialize(entity)
          @entity = entity
          @hash_rest = @entity.to_attr_hash
        end

        def delete_unneed(symbol)
          # delete unused entity fields to input to database
          @hash_rest.delete(symbol)
        end

        def create_restaurant
          delete_unneed(:cover_pictures)

          # change type to avoid sequel value misused problem
          @hash_rest[:tags] = @hash_rest[:tags].to_s
          @hash_rest[:open_hours] = @hash_rest[:open_hours].to_s
          Database::RestaurantOrm.create(@hash_rest)
        end

        def call
          # create restaurant to database and get its id
          restaurant_db_entity = create_restaurant
          restaurant_db_entity_id = restaurant_db_entity.id

          # create other related entities to database
          put_cover_pictures_to_db(restaurant_db_entity_id)

          # return restaurant entity
          restaurant_db_entity
        end

        def put_cover_pictures_to_db(restaurant_db_entity_id)
          cover_pictures = @entity.cover_pictures
          cover_pictures.map do |cover_picture|
            CoverPictures.db_find_or_create(cover_picture, restaurant_db_entity_id)
          end
        end
      end
    end
  end
end
