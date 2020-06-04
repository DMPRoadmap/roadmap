module Dmpopidor
  module Models
    module User

        # remove personal data from the user account and save
        # leave account in-place, with org for statistics (until we refactor those)
        #
        # Returns boolean
        def archive
            copy = self.dup
            self.firstname = 'Anonymous'
            self.surname = 'User'
            self.email = ::User.unique_random(field_name: 'email',
            prefix: 'user_',
            suffix: Rails.configuration.branding[:application].fetch(:archived_accounts_email_suffix, '@example.org'),
            length: 5)
            self.recovery_email = nil
            self.api_token = nil
            self.encrypted_password = nil
            self.last_sign_in_ip = nil
            self.current_sign_in_ip =  nil
            self.active = false

            self.user_identifiers.destroy_all

            Rails.logger.info "User #{self.id} anonymized"
            p "User #{self.id} anonymized"
            UserMailer.anonymization_notice(copy).deliver_now

            return self.save
        end

    end
  end
end
