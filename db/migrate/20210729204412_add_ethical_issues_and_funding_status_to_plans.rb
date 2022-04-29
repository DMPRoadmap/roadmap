class AddEthicalIssuesAndFundingStatusToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :ethical_issues, :boolean
    add_column :plans, :ethical_issues_description, :text
    add_column :plans, :ethical_issues_report, :string

    add_column :plans, :funding_status, :integer, null: true
  end
end
