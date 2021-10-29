# frozen_string_literal: true

class Users::InvitationsController < Devise::InvitationsController

  include Dmptool::Authenticatable

  before_action :configure_invite_params

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_invite_params
    devise_parameter_sanitizer.permit(
      :accept_invitation, keys: authentication_params(type: :invitation)
    )
  end

  # Override the default Devise Invitable controller to attach the User's Org
  def resource_from_invitation_token
    if params[:invitation_token] && self.resource = resource_class.find_by_invitation_token(params[:invitation_token], true)
      # If the User's Org is not defined, try to determine it based on their email
      unless resource.org_id.present?
        resource.org = org_from_email_domain(
          email_domain: resource.email&.split("@")&.last
        )
      end
    else
      set_flash_message(:alert, :invitation_token_invalid) if is_flashing_format?
      redirect_to after_sign_out_path_for(resource_name)
    end
  end

  # Override require_no_authentication method defined at DeviseController
  # (parent of Devise::InvitationsController) The following filter gets
  # executed any time GET /users/invitation/accept?invitation_token=valid_token
  # is requested. It replaces the default error message from devise
  # (e.g. You are already signed in.) if the user is signed in already while
  # trying to access to that URL
  def require_no_authentication
    super
    return unless flash[:alert].present?

    flash[:alert] = nil
    # rubocop:disable Layout/LineLength
    flash[:notice] = _("You are already signed in as another user. Please log out to activate your invitation.")
    # rubocop:enable Layout/LineLength
  end

end
