# frozen_string_literal: true

module Subscribable

  extend ActiveSupport::Concern

  included do

    # ================
    # = Associations =
    # ================

    has_many :subscriptions, as: :subscriber, dependent: :destroy

    # =====================
    # = Nested Attributes =
    # =====================

    accepts_nested_attributes_for :subscriptions

    # ====================
    # = Instance Methods =
    # ====================

    # Returns the Subscription for the specified subscriber or nil if none exists
    def subscriptions_for(plan:)
      plan = plan.is_a?(Plan) ? plan.id : plan
      subscriptions.select { |subscription| subscription.plan_id == plan }
    end

  end

end
