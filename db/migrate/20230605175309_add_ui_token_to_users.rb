class AddUiTokenToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :ui_token, :string
  end
end
