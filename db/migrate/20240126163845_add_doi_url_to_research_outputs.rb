class AddDoiUrlToResearchOutputs < ActiveRecord::Migration[6.1]
  def change
    add_column :research_outputs, :doi_url, :string
  end
end
