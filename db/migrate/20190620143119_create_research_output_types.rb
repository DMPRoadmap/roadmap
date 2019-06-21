class CreateResearchOutputTypes < ActiveRecord::Migration
  def change
    create_table :research_output_types do |t|
      t.string :label, null: false
      t.string :slug, null: false
      t.boolean :is_other, default: false, null: false

      t.timestamps null: false
    end
  end
end
