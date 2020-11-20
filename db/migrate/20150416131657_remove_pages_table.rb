class RemovePagesTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :pages
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
