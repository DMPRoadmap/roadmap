# frozen_string_literal: true

module Dmpopidor
  # Customized code for User model
  module User
    # remove personal data from the user account and save
    # leave account in-place, with org for statistics (until we refactor those)
    #
    # Returns boolean
    # rubocop:disable Metrics/AbcSize
    def archive
      suffix = Rails.configuration.x.application.fetch(:archived_accounts_email_suffix, '@example.org')
      copy = dup
      self.firstname = 'Anonymous'
      self.surname = 'User'
      self.email = ::User.unique_random(field_name: 'email',
                                        prefix: 'user_',
                                        suffix: suffix,
                                        length: 5)
      self.recovery_email = nil
      self.api_token = nil
      self.encrypted_password = nil
      self.last_sign_in_ip = nil
      self.current_sign_in_ip = nil
      self.active = false

      user_identifiers.destroy_all

      Rails.logger.info "User #{id} anonymized"
      p "User #{id} anonymized"
      UserMailer.anonymization_notice(copy).deliver_now

      save
    end
    # rubocop:enable Metrics/AbcSize
  end
end
