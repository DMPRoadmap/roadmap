class CreateUserIdentifierScheme < ActiveRecord::Migration
  def change
    create_table :identifier_schemes do |t|
      t.string :name
      t.string :logo
      t.string :api_key
      t.string :api_secret
      t.string :landing_page_uri
      t.string :params
      
      t.timestamps
    end
  end
end