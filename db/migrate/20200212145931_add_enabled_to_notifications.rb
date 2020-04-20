class AddEnabledToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :enabled, :boolean, default: true
  end
end
