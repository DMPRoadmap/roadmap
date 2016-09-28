class CreateGuidances < ActiveRecord::Migration
  def change
    create_table :guidances do |t|
      t.text :guidance_text
      t.integer :guidance_file_id
      t.integer :org_id
      t.integer :theme_id

      t.timestamps
    end
  end
end
