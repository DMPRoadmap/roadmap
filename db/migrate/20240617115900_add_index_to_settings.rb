class AddIndexToSettings < ActiveRecord::Migration[6.1]
  def change
    add_index :settings, [:target_id, :target_type], name: 'settings_target'
  end
end