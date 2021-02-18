class CreateRelatedIdentifiers < ActiveRecord::Migration[5.2]
  def change
    create_table :related_identifiers do |t|
      t.references  :identifier_scheme, null: true,  index: true
      t.integer     :identifier_type,   null: false, index: true
      t.integer     :relation_type,     null: false, index: true
      t.bigint      :identifiable_id
      t.string      :identifiable_type
      t.timestamps

      t.index [:identifiable_id, :identifiable_type, :relation_type],
              name: "index_relateds_on_identifiable_and_relation_type"
    end
  end
end
