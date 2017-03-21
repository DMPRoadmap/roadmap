class CreateDmptemplates < ActiveRecord::Migration
  def change
    create_table :dmptemplates do |t|
      t.string :template_title
      t.text :template_desc
      t.boolean :template_published
      t.integer :user_id
      t.integer :org_id

      t.timestamps
    end
  end
end
