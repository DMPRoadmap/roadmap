class AddProjectAdministratorToProjectGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :project_groups, :project_administrator, :boolean
  end
end
