class AddVersionableQuestionIdentifiers < ActiveRecord::Migration[6.1]
  def change
    add_column :question_identifiers, :versionable_id, :string, limit: 36

    add_index :question_identifiers, :versionable_id
  
  end
end
