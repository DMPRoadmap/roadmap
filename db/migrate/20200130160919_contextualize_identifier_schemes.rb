class ContextualizeIdentifierSchemes < ActiveRecord::Migration[4.2]
  def change
    add_column :identifier_schemes, :for_auth, :boolean, default: false
    add_column :identifier_schemes, :for_orgs, :boolean, default: false
    add_column :identifier_schemes, :for_plans, :boolean, default: false
    add_column :identifier_schemes, :for_users, :boolean, default: false
  end
end
