class AddLinksToTemplates < ActiveRecord::Migration[4.2]
  def change
    add_column :templates, :links, :string
  end
end
