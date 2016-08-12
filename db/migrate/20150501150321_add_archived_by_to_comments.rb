class AddArchivedByToComments < ActiveRecord::Migration
  def change
    add_column :comments, :archived_by, :integer
  end
end
