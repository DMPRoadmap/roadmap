# frozen_string_literal: true

module Csvable

  require "csv"
  class << self

    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    def from_array_of_hashes(data = [], humanize = true, sep = ",")
      return "" unless data.first&.keys

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
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

  end

end
