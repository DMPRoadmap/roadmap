# frozen_string_literal: true

class Users::InvitationsController < Devise::InvitationsController

  include OrgSelectable

  before_action :configure_invite_params

  before_action :prepare_params, only: [:update]

  # POST /users/invitation/resend
  def resend
    user = User.find_by(id: params[:id])
    if user.present? && !user.accepted_or_not_invited?
      # Resend the invitation
      user.deliver_invitation
      flash[:notice] = _("The invitation email has been re-sent to %{email}.") % {
        email: user.email
      }
    else
      flash[:alert] = _("Unable to resend your invitation.")
    end
    redirect_to root_path
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_invite_params
    devise_parameter_sanitizer.permit(
      :accept_invitation, keys: [:accept_terms, :firstname, :language_id, :org_id, :surname,
                                 org_attributes: [:name, :abbreviation, :contact_email,
                                 :contact_name, :links, :target_url, :is_other, :managed,
                                 :org_type]]
    )
  end

  def resend_params
    params.require(:user).permit(:email)
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

  # Set the Language to the one the user has selected
  def prepare_params
    unless I18n.locale.nil? || update_resource_params[:language_id].present?
      params[:user][:language_id] = Language.id_for(I18n.locale)
    end

pp update_resource_params

    # Capitalize the first and last names
    params[:user][:firstname] = update_resource_params[:firstname]&.humanize
    params[:user][:surname] = update_resource_params[:surname]&.humanize

    # Convert the selected/specified Org name into attributes
    org_params = autocomplete_to_controller_params
    params[:user][:org_id] = org_params[:org_id] if org_params[:org_id].present?
    params[:user][:org_attributes] = org_params[:org_attributes] unless org_params[:org_id].present?
  end

end
