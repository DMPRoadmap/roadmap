class AddUserLandingUrlToIdentifierSchemes < ActiveRecord::Migration
  def change
    add_column :identifier_schemes, :user_landing_url, :string
  end
end
