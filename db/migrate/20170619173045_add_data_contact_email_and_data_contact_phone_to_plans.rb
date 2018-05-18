class AddDataContactEmailAndDataContactPhoneToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :data_contact_email, :string
    add_column :plans, :data_contact_phone, :string
  end
end
