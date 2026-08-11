class RestoreSettingsIndex < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    add_index :settings,
              [:target_type, :target_id],
              name: "index_settings_on_target_type_and_target_id",
              algorithm: :concurrently
  end

  def down
    remove_index :settings,
                 name: "index_settings_on_target_type_and_target_id",
                 algorithm: :concurrently
  end
end
