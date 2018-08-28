class AddVersionableIdToPhasesSectionsAndQuestions < ActiveRecord::Migration
  def change
    add_column :phases, :versionable_id, :string
    add_column :sections, :versionable_id, :string
    add_column :questions, :versionable_id, :string
    add_column :annotations, :versionable_id, :string

    add_index :phases, :versionable_id
    add_index :sections, :versionable_id
    add_index :questions, :versionable_id
    add_index :annotations, :versionable_id
  end
end
