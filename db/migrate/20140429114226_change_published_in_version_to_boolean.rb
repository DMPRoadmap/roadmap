class ChangePublishedInVersionToBoolean < ActiveRecord::Migration[4.2]
  def change
    change_column :versions, :published, :boolean
  end
end
