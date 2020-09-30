class AddLinksToOrgs < ActiveRecord::Migration[4.2]
  def change
    add_column :orgs, :links, :string
  end
end
