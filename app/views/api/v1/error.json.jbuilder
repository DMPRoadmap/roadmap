# frozen_string_literal: true

json.partial! "api/v1/standard_response"

json.items []
json.errors @payload[:errors]
