class AddLocaleToTemplates < ActiveRecord::Migration
  def change
    add_column :dmptemplates, :locale, :string
  end
end
