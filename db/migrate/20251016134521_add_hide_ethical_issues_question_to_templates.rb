class AddHideEthicalIssuesQuestionToTemplates < ActiveRecord::Migration[7.1]
  def change
    add_column :templates, :hide_ethical_issues_question, :boolean
  end
end
