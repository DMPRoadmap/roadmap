class CreateUserRoleTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :user_role_types do |t|
      t.string :user_role_type_name
      t.text :user_role_type_desc

      t.timestamps
    end
  end
end
