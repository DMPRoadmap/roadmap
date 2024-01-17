# frozen_string_literal: true

# This Job sends a notification (the JSON version of the Plan) out to the specified
# subscriber.
class NotifySubscriberJob < ApplicationJob
  queue_as :default

  def perform(subscription)
    # TODO: We're currently only 'subscribing' the DMP ID service to plans.
    #       We can build out the rest of this if we add other subscriber types
    #       e.g. allowing an api_client associated with an Org's internal
    #       data curation or research project management systems
    case subscription.subscriber_type
    when 'ApiClient'
      notify_api_client(subscription: subscription)
      subscription.update(subscriber_job_status: 'success') if subscription.respond_to?(:subscriber_job_status)
    else
      # Maybe just use HTTParty for this if we ever want to subscribe a different model
      # like a User or Org
      true
    end

    subscription.update(last_notified: Time.zone.now)
  rescue StandardError => e
    # Something went terribly wrong, so note it in the logs since this runs outside the
    # regular Rails thread that the application is using
    Rails.logger.error "NotifySubscriberJob.perform failed for \
                        Subscription: #{subscription.inspect}"
    Rails.logger.error "NotifySubscriberJob.perform - #{e.message}"
    Rails.logger.error e.backtrace
  end

  private

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def notify_api_client(subscription:)
    return false unless subscription.present? && subscription.subscriber.present?

    api_client = subscription.subscriber
    dmp_id_svc = api_client.name.downcase == DmpIdService.identifier_scheme&.name&.downcase

    # If the ApiClient is the DMP ID service then update the DMP ID metadata
    if DmpIdService.minting_service_defined? && dmp_id_svc
      Rails.logger.info "Sending #{api_client.name} the updated DMP ID metadata \
                        for Plan #{subscription.plan.id}"

      # Publish the updated meatdata to the DMP ID record
      DmpIdService.update_dmp_id(plan: subscription.plan)
    elsif !dmp_id_svc
      # As long as this isn't the DMP ID service, send the update directly to the callback
      # Maybe just use HTTParty for this
      true
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
