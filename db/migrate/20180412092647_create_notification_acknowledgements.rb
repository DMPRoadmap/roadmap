class CreateNotificationAcknowledgements < ActiveRecord::Migration
  def change
    create_table :notification_acknowledgements do |t|
      t.belongs_to :user, foreign_key: true, index: true
      t.belongs_to :notification, foreign_key: true, index: true

      t.timestamps null: true
    end
  end
end
