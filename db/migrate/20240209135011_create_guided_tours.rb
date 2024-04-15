class CreateGuidedTours < ActiveRecord::Migration[7.1]
  def change
    create_table :guided_tours do |t|
      t.references :user, index: true, foreign_key: true
      t.string :tour
      t.boolean :ended, default: false

      t.timestamps
    end
  end
end
