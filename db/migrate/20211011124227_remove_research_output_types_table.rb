class RemoveResearchOutputTypesTable < ActiveRecord::Migration[4.2]

  def change
    remove_foreign_key :research_outputs, :research_output_types

    drop_table :research_output_types
  end

end
