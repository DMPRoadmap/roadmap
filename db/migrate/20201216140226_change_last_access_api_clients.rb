class ChangeLastAccessApiClients < ActiveRecord::Migration[5.2]
  def change
    change_column :api_clients, :last_access, :datetime
  end
end
