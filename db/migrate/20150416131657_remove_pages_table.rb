class RemovePagesTable < ActiveRecord::Migration
  def up
    drop_table :pages
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
