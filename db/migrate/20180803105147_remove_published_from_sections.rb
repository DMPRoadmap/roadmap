class RemovePublishedFromSections < ActiveRecord::Migration
  def up
    remove_column :sections, :published, :boolean
  end
  def down
    add_column :sections, :published, :boolean
  end
end
