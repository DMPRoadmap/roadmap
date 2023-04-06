class AddApiFieldsToRegistryOrgs < ActiveRecord::Migration[6.1]
  def change
    add_column :registry_orgs, :api_target, :string
    add_column :registry_orgs, :api_label, :string
    add_column :registry_orgs, :api_guidance, :text
    add_column :registry_orgs, :api_auth_target, :string
  end
end
