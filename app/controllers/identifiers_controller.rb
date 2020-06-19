# frozen_string_literal: true

class IdentifiersController < ApplicationController

  respond_to :html
  after_action :verify_authorized

  # DELETE /users/identifiers
  # ---------------------------------------------------------------------
  def destroy
    authorize Identifier
    user = User.find(current_user.id)
    identifier = Identifier.find(params[:id])

    # If the requested identifier belongs to the current user remove it
    if user.identifiers.include?(identifier)
      identifier.destroy!
      flash[:notice] = _("Successfully unlinked your account from %{is}.") % {
        is: identifier.identifier_scheme&.description
      }
    else
      flash[:alert] = _("Unable to unlink your account from %{is}.") % {
        is: identifier.identifier_scheme&.description
      }
    end

    redirect_to edit_user_registration_path
  end

end
