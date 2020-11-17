class RemoveUserIdentifiersTable < ActiveRecord::Migration[5.2]
  def up
    drop_table :user_identifiers
  end

  def down
    rails ActiveRecord::IrreversibleMigration
  end
end
