class ChangePrefsSettingsToText < ActiveRecord::Migration[4.2]
  def up
    change_column :prefs, :settings, :text
  end

  def down
    change_column :prefs, :settings, :string
  end
end
