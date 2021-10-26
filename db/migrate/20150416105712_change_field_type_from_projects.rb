class ChangeFieldTypeFromProjects < ActiveRecord::Migration[4.2]
  def change
    change_column :projects, :description, :text
  end

end
