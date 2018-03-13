class AddPrincipalInvestigatorEmailToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :principal_investigator_email, :string
  end
end
