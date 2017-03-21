class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations do |t|
      t.string :org_name
      t.string :org_abbre
      t.text :org_desc
      t.string :org_target_url
      t.integer :org_logo_file_id
      t.integer :org_banner_file_id
      t.integer :org_type_id
      t.string :org_domain
      t.integer :org_wayfless_entite
      t.integer :org_stylesheet_file_id

      t.timestamps
    end
  end
end
