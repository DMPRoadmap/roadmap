class RemoveFieldFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :note  
    remove_column :projects, :locked
  end
end
