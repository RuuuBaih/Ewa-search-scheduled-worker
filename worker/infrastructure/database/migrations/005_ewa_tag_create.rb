# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:ewa_tags) do
      primary_key :id
      foreign_key :restaurant_id, :restaurants, on_delete: :cascade

      String :ewa_tag

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
