class AddFosIdToPlans < ActiveRecord::Migration[5.2]
  def change
    add_reference :plans, :fos, index: true
  end
end
