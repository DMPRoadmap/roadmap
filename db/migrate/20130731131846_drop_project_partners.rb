class DropProjectPartners < ActiveRecord::Migration[4.2]
  def up
  	drop_table :project_partners
  end

  def down
  	create_table :project_partners do |t|
      t.integer :organisation_id
      t.integer :project_id
      t.boolean :leader_org

      t.timestamps
    end
  end
end
