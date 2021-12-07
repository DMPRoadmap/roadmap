class CreateApiLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :api_logs do |t|
      t.belongs_to  :api_client,         null: false,  index: true
      t.integer     :change_type,        null: false, index: true
      t.text        :activity
      t.bigint      :logable_id
      t.string      :logable_type
      t.timestamps

      t.index [:logable_id, :logable_type, :change_type],
              name: "index_api_logs_on_logable_and_change_type"
    end
  end
end
