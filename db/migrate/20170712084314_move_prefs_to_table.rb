class MovePrefsToTable < ActiveRecord::Migration
  def change
    remove_column :users, :prefs

    create_table :prefs do |t|
      t.string :settings
      t.integer :user_id
    end
  end
end


