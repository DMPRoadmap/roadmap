class RenameSubscribersFields < ActiveRecord::Migration[5.2]
  def change
    rename_column :subscribers, :identifiable_id, :subscriber_id
    rename_column :subscribers, :identifiable_type, :subscriber_type
    rename_column :subscribers, :subscription_type, :subscription_types
  end
end
