class RenameDatasetsToResearchOutputs < ActiveRecord::Migration
  def change
    remove_foreign_key :answers, :datasets
    remove_reference :answers, :dataset

    rename_table :datasets, :research_outputs

    add_reference :answers, :research_output, index: true, foreign_key: true
  end
end
