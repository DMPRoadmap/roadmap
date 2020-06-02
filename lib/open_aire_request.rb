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
    Rails.logger.info("Fetching fresh data from #{API_URL % funder_type}")
    data = open(API_URL % funder_type)
    Rails.logger.info("Fetched fresh data from #{API_URL % funder_type}")
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

end
