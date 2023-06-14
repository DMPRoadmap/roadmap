class RemoveNarrativeFromWips < ActiveRecord::Migration[6.1]
  def change
    remove_column :wips, :narrative_content
    remove_column :wips, :narrative_file_name
  end
end
