# frozen_string_literal: true

# This Job calls the DMPHub citation service and then saves the resulting citation info
class CitationJob < ApplicationJob
  queue_as :default

  def perform(related_identifier:)
    related_identifier = ExternalApis::DmphubService.fetch_citation(related_identifier: related_identifier)
    related_identifier.save
  rescue StandardError => e
    # Something went terribly wrong, so note it in the logs since this runs outside the
    # regular Rails thread that the application is using
    Rails.logger.error "CitationJob.perform failed with #{e.message} for #{doi}"
    Rails.logger.error e.backtrace
  end
end
