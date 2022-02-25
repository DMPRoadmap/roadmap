# frozen_string_literal: true

# IPs to allow outright
Rack::Attack.safelist_ip('127.0.0.1')
Rack::Attack.safelist_ip('::1')

# Set a long block period for any client that is explicitly looking for security holes
Rack::Attack.blocklist('malicious_clients') do |req|
  Rack::Attack::Fail2Ban.filter("fail2ban_malicious_#{req.ip}", maxretry: 1, findtime: 1.day, bantime: 1.day) do
    CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
      req.path.include?('/etc/passwd') ||
      req.path.include?('wp-admin') ||
      req.path.include?('wp-login') ||
      /\S+\.php/.match?(req.path)
  end
end

### Configure Cache ###

# If you don't want to use Rails.cache (Rack::Attack's default), then
# configure it here.
#
# Note: The store is only used for throttling (not blocklisting and
# safelisting). It must implement .increment and .write like
# ActiveSupport::Cache::Store

# Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

### Throttle Spammy Clients ###

# If any single client IP is making tons of requests, then they're
# probably malicious or a poorly-configured scraper. Either way, they
# don't deserve to hog all of the app server's CPU. Cut them off!
#
# Note: If you're serving assets through rack, those requests may be
# counted by rack-attack and this throttle may be activated too
# quickly. If so, enable the condition to exclude them from tracking.

# Throttle all requests by IP (60rpm)
#
# Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
Rack::Attack.throttle('req/ip', limit: 100, period: 1.minute) do |req|
  req.ip unless req.path.start_with?('/assets')
end

### Prevent Brute-Force Login Attacks ###

# The most common brute-force login attack is a brute-force password
# attack where an attacker simply tries a large number of emails and
# passwords to see if any credentials match.
#
# Another common method of attack is to use a swarm of computers with
# different IPs to try brute-forcing a password for a specific account.

# Throttle POST requests to /login by IP address
#
# Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
Rack::Attack.throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
  secure_paths = %w[/oauth/authorize /oauth/token /users/sign_in /users/auth/shibboleth
                    /users/auth/orcid /users/password /users]
  if secure_paths.include?(req.path) && req.post?
    req.ip
  end
end

# Throttle POST requests to /login by email param
#
# Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{normalized_email}"
#
# Note: This creates a problem where a malicious user could intentionally
# throttle logins for another user and force their login requests to be
# denied, but that's not very common and shouldn't happen to you. (Knock
# on wood!)
# throttle('logins/email', limit: 5, period: 20.seconds) do |req|
#   if req.path == '/login' && req.post?
#      # Normalize the email, using the same logic as your authentication process, to
#      # protect against rate limit bypasses. Return the normalized email if present, nil otherwise.
#      req.params['email'].to_s.downcase.gsub(/\s+/, "").presence
#  end
# end

### Custom Throttle Response ###

# By default, Rack::Attack returns an HTTP 429 for throttled responses,
# which is just fine.
#
# If you want to return 503 so that the attacker might be fooled into
# believing that they've successfully broken your app (or you just want to
# customize the response), then uncomment these lines.
# self.throttled_response = lambda do |env|
#  [ 503,  # status
#    {},   # headers
#    ['']] # body
# end

# Log the blocked requests
ActiveSupport::Notifications.subscribe(/rack_attack/) do |name, _start, _finish, _request_id, payload|
  req = payload[:request]
  Rails.logger.info "[Rack::Attack][Blocked] name: #{name}, rule: #{req.env['rack.attack.matched']} remote_ip: #{req.ip}, " \
                    "path: #{req.path}, agent: #{req.user_agent}"
end
