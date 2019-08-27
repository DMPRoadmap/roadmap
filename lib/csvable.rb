# frozen_string_literal: true

module Csvable

  require "csv"
  class << self

    def from_array_of_hashes(data = [], humanize = true)
      return "" unless data.first&.keys
      if humanize
        headers = data.first.keys
          .map(&:to_s)
          .map(&:humanize)
      else
        headers = data.first.keys
          .map(&:to_s)
      end

      CSV.generate do |csv|
        csv << headers
        data.each do |row|
          csv << row.values
        end
      end
    end

  end

end
