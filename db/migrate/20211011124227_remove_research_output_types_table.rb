class RemoveResearchOutputTypesTable < ActiveRecord::Migration

  def change
    remove_foreign_key :research_outputs, :research_output_types

    drop_table :research_output_types
  end

end
