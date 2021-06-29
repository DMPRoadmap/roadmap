class AddUserToOauthApplications < ActiveRecord::Migration[5.2]
  def change
    add_reference :oauth_applications, :user, index: true

    change_column :oauth_applications, :contact_name, :string, null: true
    change_column :oauth_applications, :contact_email, :string, null: true
  end
end
