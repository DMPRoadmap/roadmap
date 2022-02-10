class CreateApiClients < ActiveRecord::Migration[4.2]
  def change
    create_table :api_clients do |t|
      t.string :name, null: false, index: true
      t.string :description
      t.string :homepage
      t.string :contact_name
      t.string :contact_email, null: false
      t.string :client_id, null: false
      t.string :client_secret, null: false
      t.date   :last_access
      t.timestamps null: false
    end
  end
end
