class RemoveSettingsIndices < ActiveRecord::Migration
  def up
    remove_index "settings", ["target_type", "target_id"]
  end
  def down
    add_index "settings", ["target_type", "target_id"],
              name: "index_settings_on_target_type_and_target_id",
              unique: true,
              using: :btree
  end
end
