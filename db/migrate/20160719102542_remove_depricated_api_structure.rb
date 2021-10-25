class RemoveDepricatedApiStructure < ActiveRecord::Migration[4.2]
  def up
    drop_table :token_permissions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
    end
end
