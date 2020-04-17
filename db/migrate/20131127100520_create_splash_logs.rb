class CreateSplashLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :splash_logs do |t|
      t.string :destination
      t.timestamps
    end
  end
end
