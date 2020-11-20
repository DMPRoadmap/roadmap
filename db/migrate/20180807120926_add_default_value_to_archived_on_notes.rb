class AddDefaultValueToArchivedOnNotes < ActiveRecord::Migration[4.2]
  def up
    change_column :notes, :archived, :boolean, default: false, null: false
  end

  def down
    change_column :notes, :archived, :boolean, default: nil, null: true
  end
end
