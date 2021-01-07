# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
require_relative 'review'
require_relative 'article'
require_relative 'picture'
require_relative '../../restaurant_options/entities/ewa_tag'

module Ewa
  module Entity
    # Restaurant Entity
    class RestaurantDetail < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :name, Strict::String
      attribute :branch_store_name, Strict::String.optional
      attribute :town,          Strict::String.optional
      attribute :money,         Strict::Integer.optional
      attribute :city,          Strict::String.optional
      attribute :telephone,     Strict::String.optional
      attribute :cover_img,     Strict::String.optional
      attribute :tags,          Strict::Array.of(String).optional
      attribute :pixnet_rating, Strict::Float.optional
      attribute :google_rating, Strict::Float.optional
      attribute :open_hours,    Strict::Array.of(String).optional
      attribute :address,       Strict::String.optional
      attribute :website,       Strict::String.optional

      attribute :cover_pictures, Array.of(CoverPicture).optional
      attribute :clicks,        Integer.optional
      attribute :likes,         Integer.optional

      attribute :reviews,       Array.of(Review).optional
      attribute :pictures,      Array.of(Picture).optional
      attribute :ewa_tag,       EwaTag.optional
      attribute :article,       Article.optional

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end
