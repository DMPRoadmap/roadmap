class AddLinksToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :links, :string
  end
end
