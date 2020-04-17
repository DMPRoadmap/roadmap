class AddPrincipalInvestigatorEmailToPlans < ActiveRecord::Migration[4.2]
  def change
    add_column :plans, :principal_investigator_email, :string
  end
end
