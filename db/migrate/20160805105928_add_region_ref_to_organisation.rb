class AddRegionRefToOrganisation < ActiveRecord::Migration[4.2]
  def change
    add_reference :organisations, :region
  end
end
