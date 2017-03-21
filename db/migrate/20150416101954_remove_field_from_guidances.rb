class RemoveFieldFromGuidances < ActiveRecord::Migration
  def change
    remove_column :guidances, :file_id  
    remove_column :guidances, :theme_id  
    remove_column :guidances, :dmptemplate_id
  end
end
