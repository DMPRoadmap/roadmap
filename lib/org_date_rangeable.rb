# frozen_string_literal: true

module OrgDateRangeable

  def monthly_range(org: nil, start_date: nil, end_date: Date.today.end_of_month)
    query_parameters = []
    query_hash = {}

    unless org.nil?
      query_parameters << 'org_id = :org_id'
      query_hash[:org_id] = org.id
    end
    
    unless start_date.nil?
      query_parameters << 'date >= :start_date'
      query_hash[:start_date] = start_date
    end

    unless end_date.nil?
      query_parameters << 'date <= :end_date'
      query_hash[:end_date] = end_date
    end

    where(query_parameters.join(' and '), query_hash)
  end

  class << self

    def split_months_from_creation(org, &block)
      starts_at = org.created_at
      ends_at = starts_at.end_of_month
      callable = block.nil? ?
        Proc.new {} :
        lambda { | start_date, end_date| block.call(start_date, end_date) }
      enumerable = []

      while !(starts_at.future? || ends_at.future?) do
        callable.call(starts_at, ends_at)
        enumerable << { start_date: starts_at, end_date: ends_at }
        starts_at = starts_at.next_month.beginning_of_month
        ends_at = starts_at.end_of_month
      end

      enumerable
    end

  end

end
