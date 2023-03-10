# frozen_string_literal: true

# Helper for exporting to CSV format
module Csvable
  require 'csv'
  class << self
    # rubocop:disable Style/OptionalBooleanParameter
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def from_array_of_hashes(data = [], humanize = true, sep = ',')
      return '' unless data.first&.keys

      headers = if humanize
                  data.first.keys
                      .map(&:to_s)
                      .map(&:humanize)
                else
                  data.first.keys
                      .map(&:to_s)
                end

      args = { col_sep: sep }
      CSV.generate(**args) do |csv|
        csv << headers
        data.each do |row|
          csv << row.values
        end
      end
    end
    # rubocop:enable Style/OptionalBooleanParameter
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
end
