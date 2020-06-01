class AddFilteredToStats < ActiveRecord::Migration
  def change
    add_column :stats, :filtered, :boolean, default: false
  end
end
