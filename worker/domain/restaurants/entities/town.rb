# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Ewa
  module Entity
    # Town Entity
    class Town < Dry::Struct
      include Dry.Types
      attribute :id, Integer.optional
      attribute :city, Strict::String.optional
      attribute :town_name, Strict::String.optional
      attribute :page, Strict::Integer.optional
      attribute :search_times, Strict::Integer.optional

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end
