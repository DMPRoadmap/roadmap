class AddRecoveryEmailToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :recovery_email, :string
  end
end
