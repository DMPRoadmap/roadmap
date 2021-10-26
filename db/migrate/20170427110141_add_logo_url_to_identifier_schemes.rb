class AddLogoUrlToIdentifierSchemes < ActiveRecord::Migration[4.2]
  def change
    add_column :identifier_schemes, :logo_url, :string
  end
end
