module OrgDateRangeable
  def monthly_range(org:, start_date: Date.today.end_of_month, end_date: Date.today.end_of_month)
    raise ArgumentError.new('missing org') unless org.present?
    raise ArgumentError.new('missing start_date') unless start_date.respond_to?(:end_of_month)
    raise ArgumentError.new('missing end_date') unless end_date.respond_to?(:end_of_month)

    where(["org_id = ? and date >= ? and date <= ?", org.id, start_date, end_date]) 
  end

  class << self
    def split_months_from_creation(org, &block)
      starts_at = org.created_at
      ends_at = starts_at.end_of_month
      callable = block.nil? ? lambda{ |start_date, end_date| } : lambda{ | start_date, end_date| block.call(start_date, end_date) }
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
