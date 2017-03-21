class CreateOrganisationTypes < ActiveRecord::Migration
  def change
    create_table :organisation_types do |t|
      t.string :org_type_name
      t.text :org_type_desc

      t.timestamps
    end
  end
end
