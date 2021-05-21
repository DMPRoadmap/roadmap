class AddLogoToOauthApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :oauth_applications, :logo_uid, :string
    add_column :oauth_applications, :logo_name, :string
  end
end
