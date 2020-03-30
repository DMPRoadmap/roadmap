class AddEnableToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :enable, :boolean
  end
end
