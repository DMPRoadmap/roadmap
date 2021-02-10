class AddAllowDoiToOrgs < ActiveRecord::Migration[5.2]
  def change
    add_column :orgs, :allow_doi, :boolean, default: false
  end
end
