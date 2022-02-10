class AddColumnsToResearchOutputs < ActiveRecord::Migration[4.2]
  def change
    add_column :research_outputs, :pid, :string
    add_column :research_outputs, :other_type_label, :string
    
    add_reference :research_outputs, :research_output_type, index: true, foreign_key: true
  end
end
