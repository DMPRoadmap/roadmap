# frozen_string_literal: true

json.prettify!
json.ignore_nil!

json.access_token @token
json.token_type @token_type
json.expires_in @expiration
json.created_at Time.now.utc.to_s
