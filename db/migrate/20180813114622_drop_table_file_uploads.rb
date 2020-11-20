class DropTableFileUploads < ActiveRecord::Migration[4.2]
  def up
    drop_table(:file_uploads) if table_exists?(:file_uploads)
  end

  def down
    create_table "file_uploads", force: :cascade do |t|
      t.string   "name"
      t.string   "title"
      t.text     "description"
      t.integer  "size"
      t.boolean  "published"
      t.string   "location"
      t.integer  "file_type_id"
      t.datetime "created_at",   null: false
      t.datetime "updated_at",   null: false
    end
  end
end
