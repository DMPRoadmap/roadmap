class RenameResearchOutputsColumns < ActiveRecord::Migration[4.2]
  def change
    change_column :research_outputs, :description, :string

    rename_column :research_outputs, :name, :abbreviation
    rename_column :research_outputs, :description, :fullname
  end
end
