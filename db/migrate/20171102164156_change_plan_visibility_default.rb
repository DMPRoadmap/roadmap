class ChangePlanVisibilityDefault < ActiveRecord::Migration[4.2]
  def change
    change_column_default :plans, :visibility, nil  # default is application configurable
  end
end
