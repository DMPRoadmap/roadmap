module ConditionalUserMailer
  extend ActiveSupport::Concern

  # Adds following methods as class methods for the class that include this module
  included do
    # Executes a given block passed if the recipient user has the preference email key enabled
    # @param recipients {User | Enumerable } User object or any object that includes Enumerable class
    # @param key {String} - A key (dot notation) whose value is true/false and belongs to prefences.email (see config/branding.yml)
    def deliver_if(recipients: [], key:)
      raise(ArgumentError, 'key must be String') unless key.is_a?(String)
      if block_given?
        split_key = key.split('.')
        if !recipients.respond_to?(:each)
          recipients = Array(recipients)
        end
        recipients.each do |r|
          if r.respond_to?(:get_preferences)
            email_hash = r.get_preferences('email')
            should_deliver = split_key.reduce(email_hash) do |m,o|
              if m.is_a?(Hash)
                m[o.to_sym]
              else
                break
              end
            end
            yield r if should_deliver.is_a?(TrueClass)
          end
        end
        true
      else  # Block not given
        false
      end
    end
  end
end