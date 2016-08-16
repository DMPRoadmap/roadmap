class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.string :theme_title
      t.text :theme_desc

      t.timestamps
    end
  end
end
