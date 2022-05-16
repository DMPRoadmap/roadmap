class AddHelpdeskEmailToOrgs < ActiveRecord::Migration[5.2]
  def change
    add_column :orgs, :helpdesk_email, :string
  end
end
