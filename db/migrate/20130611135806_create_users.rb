class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_firstname
      t.string :user_surname
      t.string :user_email
      t.string :user_password
      t.string :user_orcid_id
      t.string :user_shibboleth_id
      t.integer :user_type_id
      t.integer :user_status_id
      t.integer :user_login_count
      t.datetime :user_last_login

      t.timestamps
    end
  end
end
