module ConditionalUserMailer
  extend ActiveSupport::Concern

  # Adds following methods as class methods for the class that include this module
  included do
    # Executes a given block passed if the recipient user has the preference email key enabled
    # @param recipient {User} - A user to look for a email preference enabled
    # @param key {String} - A key (dot notation) whose value is true/false and belongs to prefences.email (see config/branding.yml)
    def deliver_if(recipient:, key:)
      raise(ArgumentError, 'recipient must be an User object') unless recipient.is_a?(User)
      raise(ArgumentError, 'key must be String') unless key.is_a?(String)
      if block_given?
        email_hash = recipient.get_preferences('email')
        should_deliver = key.split('.').reduce(email_hash) do |m,o|
          if m.is_a?(Hash)
            m[o.to_sym]
          else
            break
          end
        end
        if should_deliver
          yield
          true
        else
          puts "User: #{recipient.name} does not have enabled the key: #{key}. The block will not be executed"
          false
        end
      else
        puts "Block not given. No need to check if key: #{key} is enabled"
        false
      end
    end
  end
end