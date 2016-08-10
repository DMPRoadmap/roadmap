class RemoveAdminUsersTable < ActiveRecord::Migration
  def up
    drop_table :admin_users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
