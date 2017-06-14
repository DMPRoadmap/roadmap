class AddPreferencesToUsers < ActiveRecord::Migration

  def self.up
    add_column :users, :prefs, :binary
  end

  def self.down
    remove_column :users, :prefs
  end
end
