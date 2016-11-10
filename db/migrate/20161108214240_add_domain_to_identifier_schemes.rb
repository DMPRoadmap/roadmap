class AddDomainToIdentifierSchemes < ActiveRecord::Migration
  def change
    add_column :identifier_schemes, :domain, :string
  end
end
