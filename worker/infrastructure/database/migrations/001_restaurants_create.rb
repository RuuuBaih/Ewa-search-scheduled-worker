# frozen_string_literal: true

require 'sequel'
Sequel.extension :migration

Sequel.migration do
  change do
    create_table(:restaurants) do
      primary_key :id

      String :name
      String :branch_store_name
      String :town
      Integer :money
      String :city
      String :telephone
      String :cover_img
      String :tags
      Float :pixnet_rating
      Float :google_rating
      String :open_hours
      String :address
      String :website
      Integer :clicks
      Integer :likes

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
