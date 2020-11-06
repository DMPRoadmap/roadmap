class CreateGuidanceGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :guidance_groups do |t|
      t.string :name
      t.references :organisation

      t.timestamps
    end
  end
end
