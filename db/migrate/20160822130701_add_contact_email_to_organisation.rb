class AddContactEmailToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :contact_email, :string
  end
end
