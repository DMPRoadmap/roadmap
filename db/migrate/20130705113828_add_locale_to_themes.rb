class AddLocaleToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :locale, :string
  end
end
