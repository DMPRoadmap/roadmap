class AddDmponline3ToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :dmponline3, :boolean
  end
end
