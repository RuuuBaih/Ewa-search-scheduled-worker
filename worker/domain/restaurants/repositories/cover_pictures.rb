# frozen_string_literal: true

require 'json'

module Ewa
  module Repository
    # Repository for Cover Pictures Entities
    class CoverPictures
      def self.all
        Database::CoverPictureOrm.all.map { |db_picture| rebuild_entity(db_picture) }
      end

      def self.find_all_cover_pics_by_restaurant_id(restaurant_id)
        rebuild_many Database::CoverPictureOrm.where(restaurant_id: restaurant_id).all
      end

      def self.db_update(new_entities, restaurant_id)
        old_entities = Database::CoverPictureOrm.where(restaurant_id: restaurant_id).all 
        old_entities.each_with_index do |db_entity, idx|
          hash_entity = new_entities[idx].to_attr_hash
          hash_entity[:restaurant_id] = restaurant_id
          db_entity.update(hash_entity)
        end
        rebuild_many old_entities
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::CoverPicture.new(
          id: db_record.id,
          picture_link: db_record.picture_link,
          article_link: db_record.article_link
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_picture|
          CoverPictures.rebuild_entity(db_picture)
        end
      end

      def self.db_find_or_create(entity, restaurant_id)
        hash_entity = entity.to_attr_hash
        hash_entity[:restaurant_id] = restaurant_id
        Database::CoverPictureOrm.find_or_create(hash_entity)
      end
    end
  end
end
