class AddAdditionalInfoToMadmpFragments < ActiveRecord::Migration[4.2]
  def change
    add_column :madmp_fragments, :additional_info, :json
  end
end
