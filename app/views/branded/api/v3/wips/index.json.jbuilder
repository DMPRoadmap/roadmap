# frozen_string_literal: true

json.partial! 'api/v3/standard_response'

json.items @wips do |wip|
  json.dmp JSON.parse(wip.to_json).fetch('dmp', {})
end
