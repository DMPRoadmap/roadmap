class ChangePublishedInVersionToBoolean < ActiveRecord::Migration
  def change
    change_column :versions, :published, :boolean
  end
end
