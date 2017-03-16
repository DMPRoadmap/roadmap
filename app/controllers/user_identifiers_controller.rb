class UserIdentifiersController < ApplicationController

  # DELETE /users/identifiers
  # ---------------------------------------------------------------------
  def destroy
    if user_signed_in? then
      user = User.find(current_user.id)
      identifier = UserIdentifier.find(params[:id])
      
      # If the requested identifier belongs to the current user remove it
      if user.user_identifiers.include?(identifier)
        identifier.destroy!
        flash[:notice] = t('identifier_schemes.disconnect_success', 
                           scheme: identifier.identifier_scheme.name)
      else
        flash[:notice] = t('identifier_schemes.disconnect_failure', 
                            scheme:  identifier.identifier_scheme.name)
      end
      
      redirect_to edit_user_registration_path
    end
  end
  
end