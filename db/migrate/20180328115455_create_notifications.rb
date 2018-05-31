class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :notification_type
      t.string :title
      t.integer :level
      t.text :body
      t.boolean :dismissable
      t.date :starts_at
      t.date :expires_at

      t.timestamps null: false
    end
  end
end
