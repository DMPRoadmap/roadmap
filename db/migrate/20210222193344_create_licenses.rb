class CreateLicenses < ActiveRecord::Migration[5.2]
  def change
    create_table :licenses do |t|
      t.string :name, null: false
      t.string :identifier, null: false, index: true
      t.string :url, null: false, index: true
      t.boolean :osi_approved, default: false
      t.boolean :deprecated, default: false
      t.timestamps
      t.index [:identifier, :osi_approved, :deprecated], name: "index_license_on_identifier_and_criteria"
    end

    add_reference :research_outputs, :license, index: true
  end
end
