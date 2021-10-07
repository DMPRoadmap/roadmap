class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references  :plan, index: true
      t.integer     :subscription_type, null: false
      t.string      :callback_uri
      t.date        :last_notified, index: true
      t.bigint      :subscribable_id
      t.string      :subscribable_type
      t.timestamps

      t.index [:subscribable_id, :subscribable_type, :plan_id],
              name: "index_subscribers_on_subscribable_and_plan_id"
    end
  end
end
