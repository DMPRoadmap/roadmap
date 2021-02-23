# frozen_string_literal: true

class PlanNotificationService

  class << self

    # Notify all of the Plan's relevant subscribers
    def notify(plan:, subscription_type:)
      return true unless processable?(subscription_type: subscription_type)

      subscribers = plan.subscribers.where("#{subscription_type}?": true)
      return true unless subscribers.any?

      subscribers.each { |subscriber| send(:"notify_of_#{subscription_type}", subscriber: subscriber) }
      true
    end

    # Perform a check to see if we can handle the requested subscription_type
    def processable?(subscription_type:)
      subscriber_good = Subscriber.new.respond_to?("#{subscription_type}?")
      service_good = respond_to?("notify_of_#{subscription_type}")
      return true if subscriber_good && service_good

      base = "#{name}.notify - "
      Rails.logger.error "#{base}Subscriber does not respond to :#{subscription_type}?" unless subscriber_good
      Rails.logger.error "#{base}does not respond to :notify_of_#{subscription_type}" unless service_good
      false
    end

    private

    # Notify the subscriber about a Plan that has been created
    def notify_of_creations(subscriber:)
      return true unless subscriber.present?

    end

    # Notify the subscriber about a Plan that has been updated
    def notify_of_updates(subscriber:)
      return true unless subscriber.present?

    end

    # Notify the subscriber about a Plan that is being destroyed
    def notify_of_deletions(subscriber:)
      return true unless subscriber.present?

    end

  end

end
