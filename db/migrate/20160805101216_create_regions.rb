class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.string :abbreviation
      t.string :description
      t.string :name
    end
  end
end
