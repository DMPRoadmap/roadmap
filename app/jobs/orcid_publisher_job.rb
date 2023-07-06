# frozen_string_literal: true

# This Job publishes a DMP ID citation to the user's ORCID record under the `works` section
class OrcidPublisherJob < ApplicationJob
  queue_as :default

  def perform(user:, plan:)
    # Only allow ORCID publication for the DMP ID if it is enabled in the config!
    if Rails.configuration.x.madmp.enable_orcid_publication
      orcid_access_token = ExternalApiAccessToken.for_user_and_service(user: user, service: 'orcid')
    end

    # If a DMP ID was successfully acquired and the User has authorized us to write to their ORCID record
    if plan.dmp_id.present? && orcid_access_token.present?
      ExternalApis::OrcidService.add_work(user: user, plan: plan)
    end
  end
end
