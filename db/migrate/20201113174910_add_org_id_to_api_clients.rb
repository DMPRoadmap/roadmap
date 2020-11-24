class AddOrgIdToApiClients < ActiveRecord::Migration[5.2]
  def change
    add_column :api_clients, :org_id, :integer
  end
end
