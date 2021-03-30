# frozen_string_literal: true

json.partial! "api/v2/standard_response", total_items: @total_items

json.items @items do |item|
  json.dmp do
    json.partial! "api/v2/plans/show", plan: item
  end
end
