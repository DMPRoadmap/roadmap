class AddPreferencesToUsers < ActiveRecord::Migration[4.2]

  def self.up
    add_column :users, :prefs, :binary
  end

  def self.down
    remove_column :users, :prefs
  end
end
