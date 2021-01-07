# frozen_string_literal: true

module Ewa
  module Repository
    # Repository for Ewa Tag Entities
    class EwaTags
      def self.find_ewa_tag_by_id(id)
        rebuild_entity Database::EwaTagOrm.first(id: id)
      end

      def self.find_ewa_tag_by_restaurant_id(restaurant_id)
        rebuild_entity Database::EwaTagOrm.first(restaurant_id: restaurant_id)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::EwaTag.new(
          id: db_record.id,
          restaurant_id: db_record.restaurant_id,
          ewa_tag: db_record.ewa_tag
        )
      end

      def self.db_find_or_create(entity, restaurant_id)
        hash_entity = entity.to_attr_hash
        hash_entity[:restaurant_id] = restaurant_id
        Database::EwaTagOrm.find_or_create(hash_entity)
      end

      def self.db_update(entity, restaurant_id)
        hash_entity = entity.to_attr_hash
        hash_entity[:restaurant_id] = restaurant_id
        db_record = Database::EwaTagOrm.first(restaurant_id: restaurant_id)
        db_record.update(hash_entity)
        db_record
      end
    end
  end
end
