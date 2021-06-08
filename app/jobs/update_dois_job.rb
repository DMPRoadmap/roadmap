# frozen_string_literal: true

class UpdateDoisJob < ApplicationJob

  queue_as :daily

  def perform(*args)
    plan = args[:plan]
    return false unless plan.present? && plan.is_a?(Plan) && plan.doi.present?

    # Loop through the plan.subscriptions

    #   Use their callback_path and callback_method to send the updated JSON
  end

end
