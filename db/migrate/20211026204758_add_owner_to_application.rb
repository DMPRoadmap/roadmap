# frozen_string_literal: true

class AddOwnerToApplication < ActiveRecord::Migration[5.2]
  def change
    remove_column :oauth_applications, :org_id
    rename_column :oauth_applications, :user_id, :owner_id
    add_column :oauth_applications, :owner_type, :string, null: true, default: "User"
    add_index :oauth_applications, [:owner_id, :owner_type]
  end
end
