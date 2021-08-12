# frozen_string_literal: true

module Subscribable

  extend ActiveSupport::Concern

  included do

    # ================
    # = Associations =
    # ================

    has_many :subscriptions, as: :subscriber, dependent: :destroy

    # ====================
    # = Instance Methods =
    # ====================

    def notify_subscribers!

    end

  end

end
