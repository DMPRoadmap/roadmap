class AddGrantNumberToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :grant_number, :string
  end
end
