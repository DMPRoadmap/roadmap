class AddLogoUrlToIdentifierSchemes < ActiveRecord::Migration
  def change
    add_column :identifier_schemes, :logo_url, :string
  end
end
