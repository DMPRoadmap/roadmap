class AddAcceptTermsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :accept_terms, :boolean
  end
end
