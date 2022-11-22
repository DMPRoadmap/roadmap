class CreateRelatedIdentifiers2 < ActiveRecord::Migration[5.2]
  def change
    create_table :related_identifiers do |t|
      t.references  :identifier_scheme, null: true,  index: true
      t.references  :plan, index: true
      t.integer     :identifier_type,   null: false, index: true
      t.integer     :relation_type,     null: false, index: true
      t.integer     :work_type,         null: false, index: true, default: 0
      t.string      :value,             null: false, index: true
      t.text        :citation
      t.bigint      :identifiable_id
      t.string      :identifiable_type
      t.timestamps

      t.index [:identifiable_id, :identifiable_type, :work_type],
              name: "index_relateds_on_identifiable_and_work_type"
    end
  end
end
