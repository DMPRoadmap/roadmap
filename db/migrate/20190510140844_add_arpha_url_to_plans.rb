class AddArphaUrlToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :arpha_url, :string
  end
end
