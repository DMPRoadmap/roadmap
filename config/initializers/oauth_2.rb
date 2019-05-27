# frozen_string_literal

module OAuth2
  ENV["HOST"] || warn("No HOST ENV variable found. OAuth 2.0 might not work as expected")
end
