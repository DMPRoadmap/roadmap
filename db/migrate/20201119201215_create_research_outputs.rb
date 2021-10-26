class CreateResearchOutputs < ActiveRecord::Migration[5.2]
  def change
    # create_table :research_outputs do |t|
    #   t.integer  :plan_id, index: true
    #   t.integer  :output_type, null: false, index: true, default: 3
    #   t.string   :output_type_description
    #   t.string   :title, null: false
    #   t.string   :abbreviation
    #   t.integer  :display_order
    #   t.boolean  :is_default
    #   t.text     :description
    #   t.integer  :mime_type_id
    #   t.integer  :access, null: false, default: 0
    #   t.datetime :release_date
    #   t.boolean  :personal_data
    #   t.boolean  :sensitive_data
    #   t.bigint   :byte_size
    #   t.text     :mandatory_attribution
    #   t.datetime :coverage_start
    #   t.datetime :coverage_end
    #   t.string   :coverage_region
    #   t.timestamps null: false
    # end
    add_column :research_outputs, :output_type, :integer, null: false, index: true, default: 3
    add_column :research_outputs, :output_type_description, :string
    add_column :research_outputs, :title, :string
    add_column :research_outputs, :display_order, :integer
    add_column :research_outputs, :is_default, :boolean
    add_column :research_outputs, :description, :text
    add_column :research_outputs, :mime_type_id, :integer
    add_column :research_outputs, :access, :integer, null: false, default: 0
    add_column :research_outputs, :release_date, :datetime
    add_column :research_outputs, :personal_data, :boolean
    add_column :research_outputs, :sensitive_data, :boolean
    add_column :research_outputs, :byte_size, :bigint
    add_column :research_outputs, :mandatory_attribution, :text
    add_column :research_outputs, :coverage_start, :datetime
    add_column :research_outputs, :coverage_end, :datetime
    add_column :research_outputs, :coverage_region, :string
end
