# frozen_string_literal: true

json.partial! 'api/v3/standard_response'

@total_items = @drafts.length
json.items @drafts do |draft|
  json.dmp JSON.parse(draft.to_json).fetch('dmp', {})
end
