class AddAllowResearchOutputsToTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :templates, :allow_research_outputs, :boolean, default: false
  end
end
