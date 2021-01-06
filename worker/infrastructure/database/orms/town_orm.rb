# frozen_string_literal: true

require 'sequel'

module Ewa
  module Database
    # Object-Relational Mapper for Articles
    class TownOrm < Sequel::Model(:towns)
      plugin :timestamps, update_on_create: true

      def self.find_or_create(town_info)
        first(id: town_info[:id]) || create(town_info)
      end
    end
  end
end
