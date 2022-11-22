class AddCitationAndWorkTypeToRelatedIdentifiers < ActiveRecord::Migration[5.2]
  def change
    add_column :related_identifiers, :work_type, :integer, index: true, default: 0
    add_column :related_identifiers, :citation, :text
  end
end
