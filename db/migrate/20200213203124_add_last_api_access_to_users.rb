class AddLastApiAccessToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :last_api_access, :datetime
  end
end
