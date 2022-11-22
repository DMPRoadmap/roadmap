class AddLanguageIdAndFeaturedToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :featured, :boolean, index: true, default: false
    add_reference :plans, :language, index: true
  end
end
