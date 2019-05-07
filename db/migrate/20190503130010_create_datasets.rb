class CreateDatasets < ActiveRecord::Migration
  def up
    create_table :datasets do |t|
      t.string :name
      t.integer :order
      t.text :description
      t.boolean :is_default, default: false
      t.belongs_to :plan, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_reference :answers, :dataset, index: true, foreign_key: true
  end

  def down
    remove_foreign_key :answers, :datasets
    remove_reference :answers, :dataset

    drop_table :datasets
  end
end
