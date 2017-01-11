class ReplacingPlanRolesWithBitflags < ActiveRecord::Migration
  def change
    # create the field to hold the user's role in plans
    add_column :roles, :access, :integer, null: false, default: 0
    # rename creator, editor, and aministrator column names so we can access data
    rename_column :roles, :creator, :create
    rename_column :roles, :editor, :edit
    rename_column :roles, :administrator, :admin
    # transfer the data from the other fields to the bitfield
    Role.find_each do |role|
      if role.admin
        role.administrator = true
      end
      if role.edit
        role.editor = true
      end
      if role.create
        role.creator = true
      end
      role.save!
    end
    # remove the other columns
    remove_column :roles, :create
    remove_column :roles, :edit
    remove_column :roles, :admin
  end
end
