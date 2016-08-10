class AddRegionRefToOrganisation < ActiveRecord::Migration
  def change
    add_reference :organisations, :region
  end
end
