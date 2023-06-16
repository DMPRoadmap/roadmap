# frozen_string_literal: true

json.ignore_nil!
json.partial! 'api/v3/standard_response'

json.items @items do |item|
  if item.is_a?(Hash)
    item.each_key do |key|
      json.set! key.to_sym, item[key]
    end
  end
end
