class CreateGuidanceGroups < ActiveRecord::Migration
  def change
    create_table :guidance_groups do |t|
      t.string :name
      t.references :organisation

      t.timestamps
    end
  end
end
