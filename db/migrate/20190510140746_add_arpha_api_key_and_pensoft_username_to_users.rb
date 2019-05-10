class AddArphaApiKeyAndPensoftUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :arpha_api_key, :string
    add_column :users, :arpha_username, :string
  end
end
