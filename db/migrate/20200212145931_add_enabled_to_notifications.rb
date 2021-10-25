class AddEnabledToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :enabled, :boolean, default: true
  end
end
