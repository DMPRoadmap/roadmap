class AddFeedbackFieldsToOrgs < ActiveRecord::Migration
  def change
    add_column :orgs, :feedback_enabled, :boolean, default: false
    add_column :orgs, :feedback_email_subject, :string
    add_column :orgs, :feedback_email_msg, :text
  end
end
