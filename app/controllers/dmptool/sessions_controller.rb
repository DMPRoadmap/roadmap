# frozen_string_literal: true

module Dmptool

  module SessionsController

    IGNORED_DOMAINS = %w[aol.com gmail.com hotmail.com yahoo.com]

    # POST /users/sign_in (via UJS form_with)
    def create

# TODO:
#   Need to trap bad email addresses
#   Cap field lengths
#   Update model to sanitize with new method
#   Finish SSO handshake (including new account more info page)
#   Tie into Devise

      @user = User.includes(:org, :identifiers)
                  .find_or_initialize_by(email: sign_in_params[:email])

      # If an org_id was passed then the user is attempting to sing in
      if !@user.new_record? && sign_in_params[:org_id].present?
        # Defer sign in to Devise
        super

      elsif @user.email.present?
        # The user provided their email address as the first step, so now try to
        # figure out who they are and let the view decide if they are signing in or
        # signing up

        if @user.can_super_admin? || @user.org.nil?
          # If this is a new user or the user is a super admin (because they can change
          # their org affiliation), try to determine what Org they belong to
          email_domain = @user.email.split("@").last
          @user.org = org_from_email_domain(email_domain: email_domain)
        end
        render
      else
        # If the email was empty of invalid
        @user.valid?
        @errors = @user.errors[:email].map { |err| "Email #{err}" }
      end
    end

    private

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in, keys: [:org_id])
    end

    # def sign_in_params
    #  params.require(:user).permit(:email, :org_id, :password)
    # end

    # Attempt to determine the Org (or RegistryOrg) based on the email's domain
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