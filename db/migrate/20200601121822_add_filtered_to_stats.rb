class AddFilteredToStats < ActiveRecord::Migration[4.2]
  def change
    add_column :stats, :filtered, :boolean, default: false
  end
end
