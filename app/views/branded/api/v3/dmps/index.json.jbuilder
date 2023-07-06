# frozen_string_literal: true

json.partial! 'api/v3/standard_response'

@total_items = @dmps.length
json.items @dmps do |dmp|
  json.dmp JSON.parse(dmp.to_json).fetch('dmp', {})
end
