class UpdateMetadataStandards < ActiveRecord::Migration[6.1]
  def change
    change_column :metadata_standards, :rdamsc_id, :string, null: true, index: false
    change_column :metadata_standards, :locations, :json, null: true
    change_column :metadata_standards, :related_entities, :json, null: true
  end
end
