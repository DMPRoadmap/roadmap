# frozen_string_literal: true

# NB: `req` is a Rack::Request object (basically an env hash with friendly accessor methods)

# Enable/disable Rack::Attack
Rack::Attack.enabled = true

# Cache store required to work.
Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new # defaults to Rails.cache

# Throttle should send a 429 Error responsec code and display public/429.html
Rack::Attack.throttled_responder = lambda do |_env|
  html = ActionView::Base.empty.render(file: 'public/429.html')
  [429, { 'Content-Type' => 'text/html' }, [html]]
end

# Throttle attempts to a particular path. 2 POSTs to /users/password every 30 seconds
Rack::Attack.throttle "password_resets/ip", limit: 2, period: 30.seconds do |req|
  req.ip if req.post? && req.path == "/users/password"
end

# Throttle attempts to a particular path. 4 POSTs to /users/sign_in every 30 seconds
Rack::Attack.throttle "logins/ip", limit: 4, period: 30.seconds do |req|
  # Don't apply sign-in rate-limiting to test environment
  (req.ip if req.post? && req.path == "/users/sign_in") unless Rails.env.test?
end

# Throttle attempts to a particular path. 2 POST or PUTS to /users every 30 seconds
# This includes password updates.
Rack::Attack.throttle "profile_updates/ip", limit: 2, period: 30.seconds do |req|
  req.ip if (req.put? || req.post?) && req.path == "/users"
end
