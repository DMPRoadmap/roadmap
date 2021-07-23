class AddApiPlanCreationEmailToOrgs < ActiveRecord::Migration[5.2]
  def change
    add_column :orgs, :api_create_plan_email_subject, :string
    add_column :orgs, :api_create_plan_email_body, :text
  end
end
