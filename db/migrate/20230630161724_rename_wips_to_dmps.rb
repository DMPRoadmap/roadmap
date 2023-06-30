class RenameWipsToDmps < ActiveRecord::Migration[6.1]
  def change
    rename_table :wips, :dmps
  end
end
