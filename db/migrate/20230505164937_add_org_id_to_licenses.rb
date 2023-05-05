class AddOrgIdToLicenses < ActiveRecord::Migration[6.1]
  def change
    change_column :licenses, :uri, :string, null: true
  end
end
