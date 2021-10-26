class CreateContributors < ActiveRecord::Migration[4.2]
  def change
    create_table :contributors do |t|
      t.string :name
      t.string :email, index: true
      t.string :phone
      t.integer :roles, index: true, null: false
      t.references :org, index: true
      t.references :plan, index: true, null: false
      t.timestamps
    end
  end
end
