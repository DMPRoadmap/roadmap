class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references  :plan, index: true
      t.integer     :subscription_type, null: false
      t.string      :callback_uri
      t.date        :last_notified, index: true
      t.bigint      :subscriber_id
      t.string      :subscriber_type
      t.timestamps

      t.index [:subscriber_id, :ssubscriber_type, :plan_id],
              name: "index_subscribers_on_subscriber_and_plan_id"
    end
  end
end
