class AddUserLandingUrlToIdentifierSchemes < ActiveRecord::Migration[4.2]
  def change
    add_column :identifier_schemes, :user_landing_url, :string
  end
end
