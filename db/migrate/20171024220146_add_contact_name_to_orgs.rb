class AddContactNameToOrgs < ActiveRecord::Migration[4.2]
  def change
    add_column :orgs, :contact_name, :string
  end
end
