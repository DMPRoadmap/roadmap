class ChangePlanVisibilityDefault < ActiveRecord::Migration
  def change
    change_column_default :plans, :visibility, nil  # default is application configurable
  end
end
