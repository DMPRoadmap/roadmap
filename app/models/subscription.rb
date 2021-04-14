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
end
