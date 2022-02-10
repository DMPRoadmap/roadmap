class AddManagedToOrgs < ActiveRecord::Migration[4.2]
  def change
    add_column :orgs, :managed, :boolean, default: false, null: false
  end
end
