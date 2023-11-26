class AddPublisherJobStatusToDrafts < ActiveRecord::Migration[6.1]
  def change
    add_column :drafts, :publisher_job_status, :string, default: 'success'
  end
end
