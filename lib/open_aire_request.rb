# frozen_string_literal

require "open-uri"
require "nokogiri"

class OpenAireRequest

  API_URL = "https://api.openaire.eu/projects/dspace/%s/ALL/ALL"

  SUPPORTED_FUNDER_TYPES = %w[nwo h2020 wellcome]

  delegate :logger, to: :Rails

  attr_reader :funder_type

  def initialize(funder_type)
    @funder_type = funder_type
  end

  def get!
    if funder_type.to_s.presence_in(SUPPORTED_FUNDER_TYPES)
      @results = results_from_api
    else
      @results = []
    end
    return self
  end

  def results
    Array(@results)
  end

  private

  def results_from_api
    logger.info("Fetching fresh data from #{API_URL % funder_type}")
    data = open(API_URL % funder_type)
    logger.info("Fetched fresh data from #{API_URL % funder_type}")
    Nokogiri::XML(data).xpath("//pair/displayed-value").map do |node|
      parts = node.content.split("-")
      grant_id = parts.shift.to_s.strip
      description = parts.join(" - ").strip
      ResearchProject.new(grant_id, description)
    end
  end

end
