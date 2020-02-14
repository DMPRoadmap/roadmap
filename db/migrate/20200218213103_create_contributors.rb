class CreateContributors < ActiveRecord::Migration
  def change
    create_table :contributors do |t|
      t.string :firstname
      t.string :surname
      t.string :email, null: false, index: true
      t.string :phone
      t.references :org, index: true
      t.timestamps
    end
  end
end