class EnableResearchOutputs < ActiveRecord::Migration[6.1]
  def change
    add_column :templates, :enable_research_outputs, :boolean, default: true
  end
end
