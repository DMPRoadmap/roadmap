class CreateFileTypes < ActiveRecord::Migration
  def change
    create_table :file_types do |t|
      t.string :file_type_name
      t.string :icon_name
      t.integer :icon_size
      t.string :icon_location

      t.timestamps
    end
  end
end
