class AddUuidToResearchOutputs < ActiveRecord::Migration[5.2]
  def change
    add_column :research_outputs, :uuid, :string
  end
end
