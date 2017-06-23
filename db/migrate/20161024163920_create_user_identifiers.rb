class CreateUserIdentifiers < ActiveRecord::Migration
  def change
    create_table :user_identifiers do |t|
      t.string :identifier
      t.timestamps
    end
    
    add_reference :user_identifiers, :user, foreign_key: true
    add_reference :user_identifiers, :identifier_scheme, foreign_key: true
  end
end
