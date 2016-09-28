class AddProjectAdministratorToProjectGroups < ActiveRecord::Migration
  def change
    add_column :project_groups, :project_administrator, :boolean
  end
end
