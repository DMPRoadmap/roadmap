class AddVisibilityToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :visibility, :integer, null: false, default: 0
  end
end
