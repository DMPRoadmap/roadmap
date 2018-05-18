class AddRecoveryEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :recovery_email, :string
  end
end
