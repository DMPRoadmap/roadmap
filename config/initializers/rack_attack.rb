# frozen_string_literal: true

# NB: `req` is a Rack::Request object (basically an env hash with friendly accessor methods)

puts "Setting up RackAttack Middleware: #{!Rails.env.test?}"

# Enable/disable Rack::Attack
Rack::Attack.enabled = !Rails.env.test?

# Cache store required to work.
Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new # defaults to Rails.cache

# Throttle should send a 429 Error responsec code and display public/429.html
Rack::Attack.throttled_responder = lambda do |_env|
  # html = ActionView::Base.empty.render(file: Rails.root.join('public/429.html'))
  # [429, { 'Content-Type' => 'text/html' }, [html]]
  details = request.env
  Rails.logger.warn("RackAttack throttled: Matched: #{details['rack.attack.matched']}, \
                     Type: #{details['rack.attack.match_type']}, Data: #{details['rack.attack.match_data']}, \
                     Discriminator: #{['rack.attack.match_discriminator']}"

  [ 429, {}, ["Too Many Requests.\n"] ]
end

# Throttle attempts to a particular path. 2 POSTs to /users/password every 30 seconds
Rack::Attack.throttle "password_resets/ip", limit: 2, period: 30.seconds do |req|
  req.post? && req.path == "/users/password/new" && req.ip
end

# Throttle attempts to a particular path. 4 POSTs to /users/sign_in every 30 seconds
Rack::Attack.throttle "logins/ip", limit: 4, period: 30.seconds do |req|
  req.post? && req.path == "/users/sign_in" && req.ip
end
