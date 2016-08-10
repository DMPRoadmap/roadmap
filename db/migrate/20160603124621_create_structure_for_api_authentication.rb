class CreateStructureForApiAuthentication < ActiveRecord::Migration
  def change
    create_table :token_permissions do |t|
      t.string  :api_token
      t.integer :token_type
      t.timestamps
    end

    create_table :token_permission_types do |t|
      t.string  :token_type
      t.text    :text_desription
      t.timestamps
    end

    create_table :org_token_permissions do |t|
      t.integer :organisation_id
      t.integer :token_type
      t.timestamps
    end

    change_table :users do |t|
      t.string :api_token
    end

  end
end
