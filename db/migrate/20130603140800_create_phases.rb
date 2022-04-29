class CreatePhases < ActiveRecord::Migration[4.2]
  def change
    create_table :phases do |t|
      t.string :title
      t.text :description
      t.integer :number
      t.references :dmptemplate

      t.timestamps
    end
    add_index :phases, :dmptemplate_id
  end
end
