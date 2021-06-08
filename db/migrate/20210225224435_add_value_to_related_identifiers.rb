class AddValueToRelatedIdentifiers < ActiveRecord::Migration[5.2]
  def change
    add_column :related_identifiers, :value, :string, null: false
  end
end
