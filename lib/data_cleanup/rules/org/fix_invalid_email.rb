# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix invalid email on Org
    module Org
      class FixInvalidEmail < Rules::Base

        def description
          "Fix invalid email on Org"
        end

        def call
          orgs_with_contact_email = ::Org.all.select(&:contact_email?)
          orgs_with_invalid_contact_email = orgs_with_contact_email.select do |org|
            validator = EmailValidator.new(allow_nil: true, attributes: :contact_email)
            validator.validate_each(org, :contact_email, org.contact_email)
          end

          orgs_with_invalid_contact_email.each do |org|
            log("Removing contact email from Org##{org.id}")
            org.contact_email = nil
            org.save(validate: false)
          end

          ::Org.where(contact_email: "").update_all(contact_email: nil)
        end
      end
    end
  end
end
