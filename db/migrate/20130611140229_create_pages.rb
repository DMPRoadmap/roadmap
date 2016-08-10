class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :pag_title
      t.text :pag_body_text
      t.string :pag_slug
      t.integer :pag_menu
      t.integer :pag_menu_position
      t.string :pag_target_url
      t.string :pag_location
      t.boolean :pag_public
      t.integer :org_id

      t.timestamps
    end
  end
end
