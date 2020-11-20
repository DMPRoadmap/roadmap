class RemoveAdminUsersTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :admin_users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
