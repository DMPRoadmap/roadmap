class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :project_title
      t.text :project_note
      t.boolean :project_locked
      t.integer :dmptemplate_id

      t.timestamps
    end
  end
end
