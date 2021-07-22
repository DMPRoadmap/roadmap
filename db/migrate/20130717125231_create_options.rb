class CreateOptions < ActiveRecord::Migration[4.2]
  def change
    create_table :options do |t|
      t.references :question
      t.string :text
      t.integer :number
      t.boolean :is_default

      t.timestamps
    end
  end
end
