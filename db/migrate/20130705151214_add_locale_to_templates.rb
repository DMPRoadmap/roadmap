class AddLocaleToTemplates < ActiveRecord::Migration[4.2]
  def change
    add_column :dmptemplates, :locale, :string
  end
end
