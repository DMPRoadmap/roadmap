class AddGrantNumberToProject < ActiveRecord::Migration
  def change
    add_column :projects, :grant_number, :string
  end
end
