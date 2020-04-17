class AddArchivedByToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :archived_by, :integer
  end
end
