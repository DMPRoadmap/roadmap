class CreateUserIdentifierScheme < ActiveRecord::Migration[4.2]
  def change
    create_table :identifier_schemes do |t|
      t.string :name
      t.string :description
      t.boolean :active
      t.timestamps
    end
  end
end