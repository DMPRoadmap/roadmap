class RemoveBannerTextFromOrgs < ActiveRecord::Migration[4.2]
  def up
    remove_column :orgs, :banner_text
  end

  def down
    add_column :orgs, :banner_text, :text
  end
end
