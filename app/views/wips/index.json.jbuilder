# frozen_string_literal: true

json.partial! 'api/v2/standard_response'

json.items @wips do |wip|
  json.identifier wip.identifier
  data = wip.metadata['dmp']
  data['dmphub_wip_id'] = { type: 'other', identifier: wip.identifier }
  json.dmp data
end
