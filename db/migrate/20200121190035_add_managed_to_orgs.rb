class AddManagedToOrgs < ActiveRecord::Migration
  def change
    add_column :orgs, :managed, :boolean, default: false, null: false
  end
end
