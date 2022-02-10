class AddActiveToOrgs < ActiveRecord::Migration[4.2]
  def change
    add_column :orgs, :active, :boolean, default: true
  end
end
