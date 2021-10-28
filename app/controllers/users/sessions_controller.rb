# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController

  before_action :configure_sign_in_params, only: [:create]

  before_action :fetch_user, only: [:create]

  # This is a customization of the Devise action that displays the sign in form
  #
  # GET /resource/sign_in
  # def new
    # super
  # end

  # POST /resource/sign_in
  def create
    if sign_in_params[:org_id].present?
      # If there is an Org in the params then this is step 2 of the email+password workflow
      # so just let Devise sign them in normally
      super

    # elsif resource.present? && resource.valid_invitation?
      # The user has an active invitation so flag this issue and render a link to resend
      # the invitation.
    #  clean_up_passwords(resource)
    #  @main_class = "js-heroimage"
    #  redirect_to root_path, alert: _("You have a pending invitation, accept it to finish creating your account. %{resend_inivitation_link} if you do not see it in your inbox.") % {
    #    resend_inivitation_link: helpers.link_to(_("Resend the invitation"), resend_invitation_path(resource))
    #  }
    else
      clean_up_passwords(resource)
      @main_class = "js-heroimage"
      render resource.new_record? ? "users/registrations/new" : :new
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:org_id])
  end

  # Lookup the user based on the email
  def fetch_user
    self.resource = User.includes(:org, :identifiers)
                        .find_or_initialize_by(email: sign_in_params[:email])

    # If the User has an invitation then clear their Org. In order to invite the
    # User we needed a default Org so the Inviter's Org was used
    self.resource.org = nil if resource.valid_invitation?

    # If the User's Org is not defined, try to determine it based on their email
    unless self.resource.org_id.present?
      self.resource.org = org_from_email_domain(
        email_domain: resource.email&.split("@")&.last
      )
    end
  end

end
