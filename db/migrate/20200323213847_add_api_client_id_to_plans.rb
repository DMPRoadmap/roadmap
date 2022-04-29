class AddApiClientIdToPlans < ActiveRecord::Migration[4.2]
  def change
    add_column :plans, :api_client_id, :integer, index: true
  end
end
