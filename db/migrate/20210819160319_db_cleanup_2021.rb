class DbCleanup2021 < ActiveRecord::Migration[5.2]
  def change
    # Removed old columns that are no longer in use
    remove_column(:answers, :label_id) if column_exists?(:answers, :label_id)

    remove_column(:orgs, :feedback_email_subject) if column_exists?(:orgs, :feedback_email_subject)
    remove_column(:orgs, :sort_name) if column_exists?(:orgs, :sort_name)

    # Rename the old feedbak email message since we no longer send an email, it's just
    # displayed on the page
    rename_column(:orgs, :feedback_email_msg, :feedback_msg) if column_exists?(:orgs, :feedback_email_msg)

    # Drop unused tables
    drop_table(:org_identifiers) if table_exists?(:org_identifiers)
    drop_table(:user_identifiers) if table_exists?(:user_identifiers)
  end
end
