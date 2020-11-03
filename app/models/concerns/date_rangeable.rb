# frozen_string_literal: true

module DateRangeable

  extend ActiveSupport::Concern

  module ClassMethods

    # Determines whether or not the search term is a date.
    # Expecting: '[month abbreviation] [year]' e.g.('Oct 2019')
    def date_range?(term:)
      term.match(/^[A-Za-z]{3,}\s+[0-9]{2,4}/).present?
    end

    # Search the specified field for the specified month
    def by_date_range(field, term)
      date = Date.parse(term) if term[0..1].match(/[0-9]{2}/).present?
      date = Date.parse("1st #{term}") unless date.present?
      query = "%{table}.%{field} BETWEEN ? AND ?" % { table: table_name, field: field }
      where(query, date, date.end_of_month)
    end

  end

end
