class Users::InvitationsController < Devise::InvitationsController
  protected
    # Override require_no_authentication method defined at DeviseController (parent of Devise::InvitationsController)
    # The following filter gets executed any time GET /users/invitation/accept?invitation_token=valid_token
    # is requested. It replaces the default error message from devise (e.g. You are already signed in.) 
    # if the user is signed in already while trying to access to that URL
    def require_no_authentication
      super
      if flash[:alert].present?
        flash[:alert] = nil
        flash[:notice] = _('You are already signed in as another user. Please log out to activate your invitation.')
      end
    end
end