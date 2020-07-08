class AddFieldColumnToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :archived, :boolean
  end
end
