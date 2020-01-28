class AddActiveToOrgs < ActiveRecord::Migration
  def change
    add_column :orgs, :active, :boolean, default: false
  end
end
