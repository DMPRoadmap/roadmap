class AddLinksToOrgs < ActiveRecord::Migration
  def change
    add_column :orgs, :links, :string
  end
end
