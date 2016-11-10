class RemoveLogoFromIdentifierSchemes < ActiveRecord::Migration
  def change
    remove_column :identifier_schemes, :logo
  end
end
