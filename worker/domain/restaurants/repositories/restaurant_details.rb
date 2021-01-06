# frozen_string_literal: true

require 'json'

module Ewa
  module Repository
    # Repository for Restaurant Details Entities
    class RestaurantDetails
      def self.all
        Database::RestaurantOrm.all.map { |db_restaurant| rebuild_entity(db_restaurant) }
      end

      def self.find(entity)
        Database::RestaurantOrm.first(name: entity.name, branch_store_name: entity.branch_store_name)
      end

      def self.update(entity, first_time = true)
        db_restaurant_detail = PersistRestaurant.new(entity).update_restaurant(first_time)
        rebuild_entity db_restaurant_detail
      end

      def self.check_update_click_status(id, limit_num)
        db_record = Database::RestaurantOrm.first(id: id)
        clicks = db_record.clicks
        if (clicks % limit_num).zero?
          true
        else
          false
        end
      end

      def self.update_click(id)
        db_record = Database::RestaurantOrm.first(id: id)
        db_record.update(
          clicks: db_record.clicks + 1
        )
        db_record.clicks
      end

      def self.find_by_rest_id(id)
        db_record = Database::RestaurantOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.rest_convert2_id(rest_name)
        db_records = Database::RestaurantOrm.where(Sequel.like(:name, "%#{rest_name}%")).all
        db_records.map do |db_record|
          rebuild_entity(db_record)
        end
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        db_record_id = db_record.id

        db_record[:tags] = JSON.parse(db_record[:tags])
        db_record[:open_hours] = JSON.parse(db_record[:open_hours])

        Entity::RestaurantDetail.new(
          db_record.to_hash.merge(
            cover_pictures: CoverPictures.find_all_cover_pics_by_restaurant_id(db_record_id),
            article: Articles.rebuild_entity(
              Articles.find_article_by_restaurant_id(db_record_id), db_record.name
            ),
            reviews: Reviews.find_all_reviews_by_restaurant_id(db_record_id),
            pictures: Pictures.find_all_pics_by_restaurant_id(db_record_id),
            ewa_tag: EwaTags.find_ewa_tag_by_restaurant_id(db_record_id)
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

        def update_restaurant(first_time)
          unneeds = %i[cover_pictures reviews article pictures ewa_tag]
          unneeds.map do |unneed|
            delete_unneed(unneed)
          end

          if first_time
            # put related gmap details into db
            put_related_details_to_db(@entity.id)
          else
            update_related_details_to_db(@entity.id)
          end

          # update infos
          db_record = Database::RestaurantOrm.first(id: @entity.id)
          db_record.update(
            google_rating: @entity.google_rating.to_f,
            website: @entity.website,
            open_hours: @entity.open_hours.to_s,
            address: @entity.address,
            clicks: db_record.clicks + 1
          )

          # return updated db_record
          db_record
        end

        def update_related_details_to_db(restaurant_db_entity_id)
          # update reviews to database
          update_reviews_to_db(restaurant_db_entity_id)

          # update article to database
          update_article_to_db(restaurant_db_entity_id)

          # update pictures to database
          update_pics_to_db(restaurant_db_entity_id)

          # update ewa_tag to database
          update_ewa_tag_to_db(restaurant_db_entity_id)
        end

        def put_related_details_to_db(restaurant_db_entity_id)
          # create reviews to database
          put_reviews_to_db(restaurant_db_entity_id)

          # create article to database
          put_article_to_db(restaurant_db_entity_id)

          # create pictures to database
          put_pics_to_db(restaurant_db_entity_id)

          # create ewa_tag to database
          put_ewa_tag_to_db(restaurant_db_entity_id)
        end

        def update_reviews_to_db(restaurant_db_entity_id)
          reviews = @entity.reviews
          true if reviews.nil?
          Reviews.db_update(reviews, restaurant_db_entity_id)
        end

        def update_article_to_db(restaurant_db_entity_id)
          article = @entity.article
          Articles.db_update(article, restaurant_db_entity_id)
        end

        def update_pics_to_db(restaurant_db_entity_id)
          pictures = @entity.pictures
          true if pictures.nil?
          Pictures.db_update(pictures, restaurant_db_entity_id)
        end

        def update_ewa_tag_to_db(restaurant_db_entity_id)
          ewa_tag = @entity.ewa_tag
          EwaTags.db_update(ewa_tag, restaurant_db_entity_id)
        end

        def put_cover_pictures_to_db(restaurant_db_entity_id)
          cover_pictures = @entity.cover_pictures
          cover_pictures.map do |cover_picture|
            CoverPictures.db_find_or_create(cover_picture, restaurant_db_entity_id)
          end
        end

        def put_reviews_to_db(restaurant_db_entity_id)
          reviews = @entity.reviews
          true if reviews.nil?
          reviews.map do |review|
            Reviews.db_find_or_create(review, restaurant_db_entity_id)
          end
        end

        def put_article_to_db(restaurant_db_entity_id)
          article = @entity.article
          Articles.db_find_or_create(article, restaurant_db_entity_id)
        end

        def put_pics_to_db(restaurant_db_entity_id)
          pictures = @entity.pictures
          true if pictures.nil?
          pictures.map do |picture|
            Pictures.db_find_or_create(picture, restaurant_db_entity_id)
          end
        end

        def put_ewa_tag_to_db(restaurant_db_entity_id)
          ewa_tag = @entity.ewa_tag
          EwaTags.db_find_or_create(ewa_tag, restaurant_db_entity_id)
        end
      end
    end
  end
end
