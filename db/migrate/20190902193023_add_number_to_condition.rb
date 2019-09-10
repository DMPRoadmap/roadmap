class AddNumberToCondition < ActiveRecord::Migration
  def change
    add_column :conditions, :number, :integer
  end
end
