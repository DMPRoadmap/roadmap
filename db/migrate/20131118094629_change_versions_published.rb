class ChangeVersionsPublished < ActiveRecord::Migration
  def change
  	change_column :versions, :published, :boolean
  end
end
