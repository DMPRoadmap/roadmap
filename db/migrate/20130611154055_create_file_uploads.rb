class CreateFileUploads < ActiveRecord::Migration
  def change
    create_table :file_uploads do |t|
      t.string :file_upload_name
      t.string :file_upload_title
      t.text :file_upload_desc
      t.integer :file_upload_size
      t.boolean :file_upload_published
      t.string :file_upload_location
      t.integer :file_type_id

      t.timestamps
    end
  end
end
