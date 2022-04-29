class CreateStaticPages < ActiveRecord::Migration[4.2]
  def change
    create_table :static_pages do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.boolean :in_navigation, default: true

      t.timestamps null: false
    end
  end
end