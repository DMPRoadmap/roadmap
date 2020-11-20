class CreateOrganisationTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :organisation_types do |t|
      t.string :org_type_name
      t.text :org_type_desc

      t.timestamps
    end
  end
end
