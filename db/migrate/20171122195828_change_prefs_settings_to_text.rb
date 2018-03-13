class ChangePrefsSettingsToText < ActiveRecord::Migration
  def up
    change_column :prefs, :settings, :text
  end

  def down
    change_column :prefs, :settings, :string
  end
end
