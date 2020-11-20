class CreateLanguages < ActiveRecord::Migration[4.2]
  def change
    create_table :languages do |t|
      t.string :abbreviation
      t.string :description
      t.string :name
    end
  end
end
