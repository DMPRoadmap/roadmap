class AddIsDefaultToDmptemplate < ActiveRecord::Migration[4.2]
  def change
    add_column :dmptemplates, :is_default, :boolean
  end
end
