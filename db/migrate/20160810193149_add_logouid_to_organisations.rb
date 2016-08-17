class AddLogouidToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :logo_uid, :string
    add_column :organisations, :logo_name, :string
  end
end
