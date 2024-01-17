class AddNarrativeToWips < ActiveRecord::Migration[6.1]
  def change
    add_column :wips, :narrative_content, :binary
    add_column :wips, :narrative_file_name, :string
  end
end
