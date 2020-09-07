class AddAdditionalInfoToMadmpFragments < ActiveRecord::Migration
  def change
    add_column :madmp_fragments, :additional_info, :json
  end
end
