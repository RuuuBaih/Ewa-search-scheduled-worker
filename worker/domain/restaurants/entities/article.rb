# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Ewa
  # Ewa project
  module Entity
    # Article Entity
    class Article < Dry::Struct
      include Dry.Types
      attribute :id, Integer.optional
      attribute :restaurant_name, Strict::String
      attribute :link, Strict::String

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end
