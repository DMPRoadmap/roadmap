class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name
      t.string :code
      t.belongs_to :org, index: true

      t.timestamps null: false
    end
    
    add_column :users, :department_id, :integer, index: true
    add_foreign_key :users, :departments

  end
end
