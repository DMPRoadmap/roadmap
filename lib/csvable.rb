# frozen_string_literal: true

module Csvable

  require "csv"
  class << self

    def from_array_of_hashes(data = [])
      return "" unless data.first&.keys
      headers = data.first.keys
        .map(&:to_s)
        .map(&:humanize)
      CSV.generate do |csv|
        csv << headers
        data.each do |row|
          csv << row.values
        end
      end
    end

  end

end
