class AddRepositoryIdToResearchOutputs < ActiveRecord::Migration[5.2]
  def change
    add_reference :research_outputs, :repository, foreign_key: true
  end
end
