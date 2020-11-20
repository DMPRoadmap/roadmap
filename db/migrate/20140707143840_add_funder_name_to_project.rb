class AddFunderNameToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :funder_name, :string
  end
end
