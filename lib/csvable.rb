# frozen_string_literal: true

<<<<<<< HEAD
module Csvable

  require "csv"
  class << self

    def from_array_of_hashes(data = [], humanize = true, sep = ",")
      return "" unless data.first&.keys
=======
# Helper for exporting to CSV format
module Csvable
  require 'csv'
  class << self
    # rubocop:disable Style/OptionalBooleanParameter
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def from_array_of_hashes(data = [], humanize = true, sep = ',')
      return '' unless data.first&.keys
>>>>>>> upstream/master

      headers = if humanize
                  data.first.keys
                      .map(&:to_s)
                      .map(&:humanize)
                else
                  data.first.keys
                      .map(&:to_s)
                end

      CSV.generate({ col_sep: sep }) do |csv|
        csv << headers
        data.each do |row|
          csv << row.values
        end
      end
    end
<<<<<<< HEAD
    # rubocop:enable

  end

=======
    # rubocop:enable Style/OptionalBooleanParameter
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
>>>>>>> upstream/master
end
