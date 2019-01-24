class RemoveLogoFileNameFromOrgs < ActiveRecord::Migration
  def up
    if column_exists?(:orgs, :logo_file_name)
      remove_column :orgs, :logo_file_name
    end
  end

  def down
    add_column :orgs, :logo_file_name, :string
  end
end
