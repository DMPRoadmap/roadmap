module Csvable
  class << self
    def from_array_of_hashes(data = [])
      headers = data.first && data.first.keys
      if headers
        return CSV.generate do |csv|
          csv << headers
          data.each do |row|
            csv << row.values
          end
        end
      end
      ''
    end
  end
end
