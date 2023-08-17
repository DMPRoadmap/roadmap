class AddJobStatusesToPlans < ActiveRecord::Migration[6.1]
  def change
    add_column :plans, :subscriber_job_status, :string, default: 'success'
    add_column :plans, :publisher_job_status, :string, default: 'success'
  end
end
