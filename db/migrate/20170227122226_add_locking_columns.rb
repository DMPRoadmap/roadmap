class AddLockingColumns < ActiveRecord::Migration[4.2]
  def self.up
    add_column  :answers, :lock_version, :integer, :default => 0
  end

  def self.down
    remove_column  :answers, :lock_version
  end
end
