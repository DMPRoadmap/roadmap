class AddIsDefaultToDmptemplate < ActiveRecord::Migration
  def change
    add_column :dmptemplates, :is_default, :boolean
  end
end
