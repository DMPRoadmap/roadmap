class FixInvalidMysqlIndices < ActiveRecord::Migration
  def up
    if index_exists?("settings", ["target_type", "target_id", "var"])
      remove_index "settings", ["target_type", "target_id", "var"]

      add_index "settings", ["target_type", "target_id"],
                  name: "index_settings_on_target_type_and_target_id",
                  unique: true
    end
  end

  def down
    if index_exists?("settings", ["target_type", "target_id"])
      remove_index "settings", ["target_type", "target_id"]
      add_index "settings", ["target_type", "target_id", "var"],
                  name: "index_settings_on_target_type_and_target_id_and_var",
                  unique: true
    end
  end
end
