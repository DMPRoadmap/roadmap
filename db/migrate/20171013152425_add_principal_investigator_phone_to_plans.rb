class AddPrincipalInvestigatorPhoneToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :principal_investigator_phone, :string
  end
end
