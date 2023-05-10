class TemplateMetadataStandards < ActiveRecord::Migration[6.1]
  def change
    create_table :template_metadata_standards do |t|
      t.belongs_to :template, type: :integer, foreign_key: true, index: true
      t.belongs_to :metadata_standard, foreign_key: true, index: true
    end
  end
end
