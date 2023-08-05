# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id                 :bigint           not null, primary key
#  callback_uri       :string
#  last_notified      :datetime
#  subscriber_type    :string
#  subscription_types :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  plan_id            :bigint
#  subscriber_id      :bigint
#
# Indexes
#
#  index_subscribers_on_identifiable_and_plan_id  (subscriber_id,subscriber_type,plan_id)
#  index_subscriptions_on_plan_id                 (plan_id)
#
class Subscription < ApplicationRecord
  include FlagShihTzu

  # ================
  # = Associations =
  # ================

  belongs_to :plan
  belongs_to :subscriber, polymorphic: true

  ##
  # Define Bit Field values for subscription_types
  has_flags 1 => :updates,
            2 => :deletions,
            3 => :creations,
            column: 'subscription_types'

  # ====================
  # = Instance Methods =
  # ====================

  def notify!
    # Do not notify anyone if this is a new record
    return false if new_record?
    # Do not notify if there is no callback or they've already been notified
    return false unless callback_uri.present? &&
                        (last_notified.nil? || last_notified < plan.updated_at)
    # Don't kick of the job if it is already enqueued!
    return false if self.respond_to?(:subscriber_job_status) && self.subscriber_job_status == 'enqueued'

    self.update(subscriber_job_status: 'enqueued') if self.respond_to?(:subscriber_job_status)
    NotifySubscriberJob.set(wait: 30.seconds).perform_later(self)
    true
  end
end
