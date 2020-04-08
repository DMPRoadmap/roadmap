class AddContextToIdentifierSchemes < ActiveRecord::Migration
  def change
    remove_column :identifier_schemes, :for_auth
    remove_column :identifier_schemes, :for_orgs
    remove_column :identifier_schemes, :for_plans
    remove_column :identifier_schemes, :for_users
    rename_column :identifier_schemes, :identifier_prefix

    add_column :identifier_schemes, :context, :integer, index: true

    change_column :identifiers, :identifier_scheme_id, :integer, null: true
    add_index :identifiers, [:identifier_scheme, :identifiable_id, :identifiable_type]
  end
end
