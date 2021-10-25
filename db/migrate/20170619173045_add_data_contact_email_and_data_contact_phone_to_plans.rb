class AddDataContactEmailAndDataContactPhoneToPlans < ActiveRecord::Migration[4.2]
  def change
    add_column :plans, :data_contact_email, :string
    add_column :plans, :data_contact_phone, :string
  end
end
