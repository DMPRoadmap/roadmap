# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id                :bigint           not null, primary key
#  callback_uri      :string
#  subscriber_type   :string
#  subscription_type :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  subscriber_id     :bigint
#  plan_id           :bigint
#  last_notified     :datetime
#
# Indexes
#
#  index_subscribers_on_identifiable_and_plan_id  (subscriber_id,subscriber_type,plan_id)
#  index_subscribers_on_plan_id                   (plan_id)
#  index_subsciprions_on_last_notifed             (last_notifed)
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
            column: "subscription_types"

  # ====================
  # = Instance Methods =
  # ====================

  def notify!
    # Do not notify if there is no callback or they've already been notified
    return false unless callback_uri.present? && last_notified < plan.updated_at

    # TODO: Update the ApiClient and this model to store the callback information.
    #       then replace the Plan.notify_subscribers logic.
    #       We should likely store the base portion of the callback_uri on the ApiClient
    #       record and let this record store the unique DMP identify there are looking for.

    update(last_notified: Time.now)
  end
end
