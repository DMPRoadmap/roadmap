class CreateIdentifiers < ActiveRecord::Migration[4.2]
  def change
    create_table :identifiers do |t|
      t.string     :value, null: false
      t.text       :attrs
      t.references :identifier_scheme, null: false
      t.references :identifiable, polymorphic: true
      t.timestamps
    end

    add_index :identifiers, [:identifiable_type, :identifiable_id]
    add_index :identifiers, [:identifier_scheme_id, :value]
  end
end
