class AddDmponline3ToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dmponline3, :boolean
  end
end
