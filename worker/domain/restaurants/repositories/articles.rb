# frozen_string_literal: true

module Ewa
  module Repository
    # Repository for Articles
    class Articles
      def self.find_article_by_id(id, restaurant_name)
        rebuild_entity(Database::ArticleOrm.first(id: id), restaurant_name)
      end

      def self.find_article_by_restaurant_id(restaurant_id)
        Database::ArticleOrm.first(restaurant_id: restaurant_id)
      end

      def self.rebuild_entity(db_record, restaurant_name)
        return nil unless db_record

        Entity::Article.new(
          id: db_record.id,
          restaurant_name: restaurant_name,
          link: db_record.link
        )
      end

      def self.db_find_or_create(entity, restaurant_id)
        hash_entity = entity.to_attr_hash
        hash_entity[:restaurant_id] = restaurant_id
        # delete the field what database doesn't have
        hash_entity.delete(:restaurant_name)
        Database::ArticleOrm.find_or_create(hash_entity)
      end

      def self.db_update(entity, restaurant_id)
        hash_entity = entity.to_attr_hash
        hash_entity[:restaurant_id] = restaurant_id
        hash_entity.delete(:restaurant_name)
        db_record = Database::ArticleOrm.first(restaurant_id: restaurant_id)
        db_record.update(hash_entity)
        db_record
      end
    end
  end
end
