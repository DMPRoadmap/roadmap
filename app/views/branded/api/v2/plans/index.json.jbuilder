# frozen_string_literal: true

json.partial! 'api/v2/standard_response', total_items: @total_items

json.items @items do |item|
  if item.is_a?(Plan)
    json.dmp do
      json.partial! 'api/v2/plans/show', plan: item
    end
  elsif item.is_a?(Draft)
    json.dmp item.metadata['dmp']
  end
end
