class AddNarrativeUrlToPlans < ActiveRecord::Migration[6.1]
  def change
    add_column :plans, :narrative_url, :string
  end
end
