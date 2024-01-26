class AddIsRecommendedToTemplates < ActiveRecord::Migration[7.1]
  def change
    add_column :templates, :is_recommended, :boolean, default: false
  end
end
