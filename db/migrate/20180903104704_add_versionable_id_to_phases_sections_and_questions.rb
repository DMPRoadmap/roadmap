class AddVersionableIdToPhasesSectionsAndQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :phases, :versionable_id, :string, limit: 36
    add_column :sections, :versionable_id, :string, limit: 36
    add_column :questions, :versionable_id, :string, limit: 36
    add_column :annotations, :versionable_id, :string, limit: 36

    add_index :phases, :versionable_id
    add_index :sections, :versionable_id
    add_index :questions, :versionable_id
    add_index :annotations, :versionable_id
  end
end
