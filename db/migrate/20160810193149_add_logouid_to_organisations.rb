class AddLogouidToOrganisations < ActiveRecord::Migration[4.2]
  def change
    add_column :organisations, :logo_uid, :string
    add_column :organisations, :logo_name, :string
  end
end
