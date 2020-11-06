class DropTableSplashLogs < ActiveRecord::Migration[4.2]
  def up
    drop_table(:splash_logs) if table_exists?(:splash_logs)
  end

  def down
    create_table "splash_logs", force: :cascade do |t|
      t.string   "destination"
      t.datetime "created_at",  null: false
      t.datetime "updated_at",  null: false
    end
  end
end
