# frozen_string_literal: true

module Dmptool

  module SessionsController

    IGNORED_DOMAINS = %w[aol.com gmail.com hotmail.com yahoo.com]

    # POST /users/sign_in (via UJS form_with)
    def create

# TODO:
#   Need to trap bad email addresses
#   Cap field lengths
#   Add recaptcha
#   Update model to sanitize with new method
#   Hook up JS
#   Finish SSO handshake (including new account more info page)
#   Tie into Devise

      @user = User.includes(:org, :identifiers)
                  .find_or_initialize_by(email: session_params[:email])

      # If this is a new user or the user is a super admin (because they can change their
      # org affiliation), try to determine what Org they belong to
      if @user.can_super_admin? || @user.org.nil?
        email_domain = @user.email.split("@").last
        @user.org = org_from_email_domain(email_domain: email_domain)
      end
    end

    private

    def session_params
      params.require(:user).permit(:email)
    end

    def org_from_email_domain(email_domain:)
      return nil unless email_domain.present?
      return nil if IGNORED_DOMAINS.include?(email_domain.downcase)

      registry_org = RegistryOrg.by_domain(email_domain).first
      return registry_org.org if registry_org.present? && registry_org.org.present?

      hash = User.where("email LIKE ?", "%@#{email_domain.downcase}").group(:org_id).count
      return nil unless hash.present?

      selected = hash.select { |k, v| v == hash.values.sort { |a, b| b <=> a }.first }
      Org.find_by(id: selected.keys.first)
    end
  end

end