# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:reviews) do
      primary_key :id
      foreign_key :restaurant_id, :restaurants, on_delete: :cascade

      String :author_name
      String :profile_photo_url
      String :relative_time_description
      Float :rating
      String :text

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
