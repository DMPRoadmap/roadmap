class AddTestAndPublicToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :is_test, :boolean, default: false
    add_column :projects, :is_public, :boolean, default: false
  end
end
