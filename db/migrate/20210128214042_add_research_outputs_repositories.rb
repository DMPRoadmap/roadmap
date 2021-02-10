class AddResearchOutputsRepositories < ActiveRecord::Migration[5.2]
  def change
    create_table :repositories_research_outputs do |t|
      t.belongs_to :research_output
      t.belongs_to :repository
    end
  end
end
