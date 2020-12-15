class DropOrgIdentifiers < ActiveRecord::Migration[5.2]
  def change
    drop_table :org_identifiers
  end
end
