class ChangeApiLabelOnRegistryOrgs < ActiveRecord::Migration[6.1]
  def change
    remove_column :registry_orgs, :api_label
    add_column :registry_orgs, :api_query_fields, :json
  end
end
