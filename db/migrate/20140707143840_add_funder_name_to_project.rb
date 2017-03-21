class AddFunderNameToProject < ActiveRecord::Migration
  def change
    add_column :projects, :funder_name, :string
  end
end
