# frozen_string_literal: true

require 'json'

module Ewa
  module Repository
    # Repository for Pictures Entities
    class Pictures
      def self.all
        Database::PictureOrm.all.map { |db_picture| rebuild_entity(db_picture) }
      end

      def self.find_all_thumb_pics_by_restaurant_id(restaurant_id)
        rebuild_many Database::PictureOrm.where(restaurant_id: restaurant_id, thumb: true).all
      end

      def self.find_all_non_thumb_pics_by_restaurant_id(restaurant_id)
        rebuild_many Database::PictureOrm.where(restaurant_id: restaurant_id, thumb: false).all
      end

      def self.find_all_pics_by_restaurant_id(restaurant_id)
        rebuild_many Database::PictureOrm.where(restaurant_id: restaurant_id).all
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Picture.new(
          id: db_record.id,
          link: db_record.link,
          thumb: db_record.thumb
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_picture|
          Pictures.rebuild_entity(db_picture)
        end
      end

      def self.db_find_or_create(entity, restaurant_id)
        hash_entity = entity.to_attr_hash
        hash_entity[:restaurant_id] = restaurant_id
        Database::PictureOrm.find_or_create(hash_entity)
      end

      def self.db_update(new_entities, restaurant_id)
        old_entities = Database::PictureOrm.where(restaurant_id: restaurant_id).all 
        old_entities.each_with_index do |db_entity, idx|
          hash_entity = new_entities[idx].to_attr_hash
          hash_entity[:restaurant_id] = restaurant_id
          db_entity.update(hash_entity)
        end
      end
    end
  end
end
