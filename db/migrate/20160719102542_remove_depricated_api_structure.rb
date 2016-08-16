class RemoveDepricatedApiStructure < ActiveRecord::Migration
  def up
    drop_table :token_permissions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
    end
end
