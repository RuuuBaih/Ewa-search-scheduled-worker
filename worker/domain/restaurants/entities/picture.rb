# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Ewa
  module Entity
    # Picture  Entity
    class Picture < Dry::Struct
      include Dry.Types
      attribute :id, Integer.optional
      attribute :link, Strict::String.optional
      attribute :thumb, Strict::Bool.optional

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end
