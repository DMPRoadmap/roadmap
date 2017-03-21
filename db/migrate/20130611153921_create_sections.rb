class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :section_title
      t.text :section_desc
      t.integer :section_order
      t.integer :version_id
      t.integer :org_id

      t.timestamps
    end
  end
end
