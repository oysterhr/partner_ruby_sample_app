# frozen_string_literal: true

class CreateClients < ActiveRecord::Migration[7.1]
  def change
    create_table :clients do |t|
      t.string :client_id
      t.string :refresh_token
      t.string :access_token

      t.timestamps

      t.index :client_id, unique: true
    end
  end
end
