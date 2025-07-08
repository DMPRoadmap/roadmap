class CreateOrgDomains < ActiveRecord::Migration[7.1]
  def change
    create_table :org_domains do |t|
      t.references :org, foreign_key: true, null: false
      t.text :domain, null: false

      t.timestamps  # Automatically adds created_at and updated_at with default non-null constraint.
    end
  end
end
