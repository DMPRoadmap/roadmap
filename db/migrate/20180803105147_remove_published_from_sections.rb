class RemovePublishedFromSections < ActiveRecord::Migration[4.2]
  def up
    remove_column :sections, :published, :boolean
  end
  def down
    add_column :sections, :published, :boolean
  end
end
