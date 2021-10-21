class CreateResearchOutputs < ActiveRecord::Migration[5.2]
  def change
    create_table :research_outputs do |t|
      t.integer  :plan_id, index: true
      t.integer  :output_type, null: false, index: true, default: 3
      t.string   :output_type_description
      t.string   :title, null: false
      t.string   :abbreviation
      t.integer  :display_order
      t.boolean  :is_default
      t.text     :description
      t.integer  :mime_type_id
      t.integer  :access, null: false, default: 0
      t.datetime :release_date
      t.boolean  :personal_data
      t.boolean  :sensitive_data
      t.bigint   :byte_size
      t.text     :mandatory_attribution
      t.datetime :coverage_start
      t.datetime :coverage_end
      t.string   :coverage_region
      t.timestamps null: false
    end
  end
end
