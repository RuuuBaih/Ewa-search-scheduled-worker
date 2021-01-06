# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:pictures) do
      primary_key :id
      foreign_key :restaurant_id, :restaurants, on_delete: :cascade

      String :link
      Bool :thumb

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
