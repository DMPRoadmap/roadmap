class AddPrincipalInvestigatorPhoneToPlans < ActiveRecord::Migration[4.2]
  def change
    add_column :plans, :principal_investigator_phone, :string
  end
end
