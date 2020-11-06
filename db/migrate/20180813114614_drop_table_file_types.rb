class DropTableFileTypes < ActiveRecord::Migration[4.2]

  def up
    drop_table(:file_types) if table_exists?(:file_types)
  end

  def down
    create_table "file_types", force: :cascade do |t|
      t.string   "name"
      t.string   "icon_name"
      t.integer  "icon_size"
      t.string   "icon_location"
      t.datetime "created_at",    null: false
      t.datetime "updated_at",    null: false
    end
  end
end
