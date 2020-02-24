class AddActiveToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :active, :boolean
  end
end
