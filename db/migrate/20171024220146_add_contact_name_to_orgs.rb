class AddContactNameToOrgs < ActiveRecord::Migration
  def change
    add_column :orgs, :contact_name, :string
  end
end
