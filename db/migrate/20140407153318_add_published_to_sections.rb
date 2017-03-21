class AddPublishedToSections < ActiveRecord::Migration
  def change
  	add_column :sections, :published, :boolean
  end
end
