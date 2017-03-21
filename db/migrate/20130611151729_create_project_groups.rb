class CreateProjectGroups < ActiveRecord::Migration
  def change
    create_table :project_groups do |t|
      t.boolean :project_creator
      t.boolean :project_editor
      t.integer :user_id
      t.integer :project_id

      t.timestamps
    end
  end
end
