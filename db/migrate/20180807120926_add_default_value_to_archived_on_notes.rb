class AddDefaultValueToArchivedOnNotes < ActiveRecord::Migration
  def up
    change_column :notes, :archived, :boolean, default: false, null: false
  end

  def down
    change_column :notes, :archived, :boolean, default: nil, null: true
  end
end
