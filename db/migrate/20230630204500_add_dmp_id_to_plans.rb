class AddDmpIdToPlans < ActiveRecord::Migration[6.1]
  def change
    add_column :plans, :dmp_id, :string
  end
end
