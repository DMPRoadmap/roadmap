class RemoveFieldFromProjects < ActiveRecord::Migration[4.2]
  def change
    remove_column :projects, :note  
    remove_column :projects, :locked
  end
end
