class RenameDmpsToDrafts < ActiveRecord::Migration[6.1]
  def change
    rename_column :dmps, :identifier, :draft_id
    rename_table :dmps, :drafts
  end
end
