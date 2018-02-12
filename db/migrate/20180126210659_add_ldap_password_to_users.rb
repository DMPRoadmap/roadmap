class AddLdapPasswordToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :ldap_password, :string
  end
end
