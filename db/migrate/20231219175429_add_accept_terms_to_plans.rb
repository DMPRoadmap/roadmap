class AddAcceptTermsToPlans < ActiveRecord::Migration[6.1]
  def change
    add_column :plans, :accept_terms, :boolean, default: false
  end
end
