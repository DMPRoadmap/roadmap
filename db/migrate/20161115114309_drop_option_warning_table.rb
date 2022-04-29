class DropOptionWarningTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :option_warnings
  end
end
