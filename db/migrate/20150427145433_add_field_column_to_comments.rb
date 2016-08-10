class AddFieldColumnToComments < ActiveRecord::Migration
  def change
    add_column :comments, :archived, :boolean
  end
end
