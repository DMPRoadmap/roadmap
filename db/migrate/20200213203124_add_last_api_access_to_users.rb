class AddLastApiAccessToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_api_access, :datetime
  end
end
