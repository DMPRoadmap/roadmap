class AddOrgIdToApiClients < ActiveRecord::Migration
  def change
    add_reference :api_clients, :org, foreign_key: true
  end
end
