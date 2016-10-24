class CreateUserIdentifierScheme < ActiveRecord::Migration
  def change
    create_table :identifier_schemes do |t|
      t.string :name
      t.string :auth_uri
      t.string :user_uri
      
      t.timestamps
    end
  end
end