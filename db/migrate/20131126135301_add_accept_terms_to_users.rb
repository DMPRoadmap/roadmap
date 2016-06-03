class AddAcceptTermsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :accept_terms, :boolean
  end
end
