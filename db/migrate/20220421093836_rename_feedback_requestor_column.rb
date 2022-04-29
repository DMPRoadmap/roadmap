class RenameFeedbackRequestorColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column(:plans, :feedback_requestor, :feedback_requestor_id) if column_exists?(:plans, :feedback_requestor)
  end
end
