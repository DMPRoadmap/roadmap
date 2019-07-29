class RenameLogicActionToCondition < ActiveRecord::Migration
  def change
  	rename_table :logic_actions, :conditions
  end
end
