class AddWebhookDataToConditions < ActiveRecord::Migration
  def change
    add_column :conditions, :webhook_data, :string
  end
end
