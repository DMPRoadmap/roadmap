class CreateApiClientRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :api_client_roles do |t|
      t.integer :access, default: 0, null: false
      t.references :api_client, index: true, null: false
      t.references :plan, index: true, null: false
      t.references :research_output, index: true
      t.timestamps
    end
  end
end
