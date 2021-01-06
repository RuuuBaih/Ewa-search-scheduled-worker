# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Ewa
  module Entity
    # Review Entity
    class Review < Dry::Struct
      include Dry.Types
      attribute :id, Integer.optional
      attribute :author_name, String.optional
      attribute :profile_photo_url, Strict::String.optional
      attribute :relative_time_description, Strict::String.optional
      attribute :text, Strict::String.optional
      attribute :rating, Strict::Float.optional

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end
