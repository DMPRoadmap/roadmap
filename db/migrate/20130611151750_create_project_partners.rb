class CreateProjectPartners < ActiveRecord::Migration[4.2]
  def change
    create_table :project_partners do |t|
      t.integer :org_id
      t.integer :project_id
      t.boolean :leader_org

      t.timestamps
    end
  end
end
