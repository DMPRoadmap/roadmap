class ChangeResearchOutputsOutputType < ActiveRecord::Migration[6.1]
  def change
    add_column :research_outputs, :research_output_type, :string, default: 'dataset', null: false
  end
end
