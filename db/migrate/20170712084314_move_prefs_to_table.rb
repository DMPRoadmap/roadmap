class MovePrefsToTable < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :prefs

    create_table :prefs do |t|
      t.string :settings
      t.integer :user_id
    end
  end
end


