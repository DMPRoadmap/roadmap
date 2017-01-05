class CreateVisibilities < ActiveRecord::Migration
  def change
    create_table :visibilities do |t|
      t.string :name
      t.boolean :default, default: false
      t.timestamps
    end
    
    add_reference :projects, :visibility, foreign_key: true
  end
end
