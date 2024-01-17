# frozen_string_literal: true

json.partial! 'api/v3/standard_response'

json.items []
json.errors @payload[:errors]
