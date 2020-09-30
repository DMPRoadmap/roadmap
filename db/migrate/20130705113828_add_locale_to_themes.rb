class AddLocaleToThemes < ActiveRecord::Migration[4.2]
  def change
    add_column :themes, :locale, :string
  end
end
