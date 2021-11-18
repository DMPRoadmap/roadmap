class AddApiClientIdToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :api_client_id, :integer, index: true
  end
end
