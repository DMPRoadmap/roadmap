class AddIsTestAndVisibilityToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :is_test, :boolean, default: false
    add_column :projects, :visibility, :integer, default: 0
  end
end
