class CreateUserOrgRoles < ActiveRecord::Migration
  def change
    create_table :user_org_roles do |t|
      t.integer :user_id
      t.integer :org_id
      t.integer :user_role_type_id

      t.timestamps
    end
  end
end
