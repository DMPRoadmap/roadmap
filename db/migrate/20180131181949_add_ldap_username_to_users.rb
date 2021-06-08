class AddLdapUsernameToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :ldap_username, :string
  end
end
