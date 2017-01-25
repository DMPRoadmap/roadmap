class DropOptionWarningTable < ActiveRecord::Migration
  def change
    drop_table :option_warnings
  end
end
