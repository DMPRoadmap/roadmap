class AddPublishedToSections < ActiveRecord::Migration[4.2]
  def change
  	add_column :sections, :published, :boolean
  end
end
