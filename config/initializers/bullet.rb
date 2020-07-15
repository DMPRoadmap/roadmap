# frozen_string_literal: true

if defined?(Bullet)
  Bullet.tap do |config|
    config.enable = true
    # config.alert = true
    config.bullet_logger = true
    config.console = true
    # config.growl = true
    # config.xmpp = { :account  => 'bullets_account@jabber.org',
    #                 :password => 'bullets_password_for_jabber',
    #                 :receiver => 'your_account@jabber.org',
    #                 :show_online_status => true }
    config.rails_logger = true
    # config.honeybadger = true
    # config.bugsnag = true
    # config.airbrake = true
    # config.rollbar = true
    config.add_footer = true
    # config.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
    # config.stacktrace_excludes = [ 'their_gem', 'their_middleware' ]
    # config.slack = {
    #   webhook_url: 'http://some.slack.url', channel: '#default', username: 'notifier'
    # }
  end
end
