# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Ewa
  module Entity
    # One restaurant pick of 9 restaurant options
    class EwaTag < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :ewa_tag, Strict::String.optional

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end
