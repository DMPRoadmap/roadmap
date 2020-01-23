# frozen_string_literal

require "open-uri"
require "nokogiri"

class OpenAireRequest

  API_URL = "https://api.openaire.eu/projects/dspace/%s/ALL/ALL"

  attr_reader :funder_type

  def initialize(funder_type)
    @funder_type = funder_type
  end

  def get!
    return self unless api_url.present?

    Rails.logger.info("Fetching fresh data from #{api_url % funder_type}")
    data = open(api_url % funder_type)
    Rails.logger.info("Fetched fresh data from #{api_url % funder_type}")
    @results = Nokogiri::XML(data).xpath("//pair/displayed-value").map do |node|
      parts = node.content.split("-")
      grant_id = parts.shift.to_s.strip
      description = parts.join(" - ").strip
      ResearchProject.new(grant_id, description)
    end
    return self
  end

  def results
    Array(@results)
  end

  def api_url
    Rails.configuration.x.open_aire&.api_url
  end

end
