class CreatePlansContributors < ActiveRecord::Migration
  def change
    create_table :plans_contributors do |t|
      t.references :contributor, index: true
      t.references :plan, index: true
      t.integer :roles, index: true
      t.timestamps
    end
  end
end