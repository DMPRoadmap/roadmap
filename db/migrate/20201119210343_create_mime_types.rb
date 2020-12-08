class CreateMimeTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :mime_types do |t|
      t.string :description, null: false
      t.string :category, null: false
      t.string :value, null: false, index: true
      t.timestamps
    end
  end
end
