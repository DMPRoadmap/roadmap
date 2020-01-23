class AddManagedToOrgs < ActiveRecord::Migration
  def change
    add_column :orgs, :managed, :boolean, default: 0, null: false
  end
end
