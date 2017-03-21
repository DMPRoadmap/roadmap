class CreateUserStatuses < ActiveRecord::Migration
  def change
    create_table :user_statuses do |t|
      t.string :user_status_name
      t.text :user_status_desc

      t.timestamps
    end
  end
end
