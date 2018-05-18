class CreateOrgIdentifiers < ActiveRecord::Migration
  def change
    create_table :org_identifiers do |t|
      t.string :identifier
      t.string :attrs
      t.timestamps
    end
    
    add_reference :org_identifiers, :org, foreign_key: true
    add_reference :org_identifiers, :identifier_scheme, foreign_key: true
  end
end
