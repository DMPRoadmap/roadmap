class AddZenodoAccessTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :zenodo_access_token, :string
  end
end
