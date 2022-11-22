# frozen_string_literal: true

module Helpers
  module EmailHelper
    def clear_emails
      ActionMailer::Base.deliveries = []
    end

    def sent_emails
      ActionMailer::Base.deliveries
    end
  end
end
