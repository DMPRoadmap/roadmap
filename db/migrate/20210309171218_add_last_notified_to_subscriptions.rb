class AddLastNotifiedToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :last_notified, :datetime, index: true
  end
end
