# frozen_string_literal: true

module SuperAdmin

  class UsersController < ApplicationController

    after_action :verify_authorized

    def edit
      @user = User.find(params[:id])
      authorize @user
      render "super_admin/users/edit",
             locals: { user: @user,
                       languages: @languages,
                       orgs: @orgs,
                       identifier_schemes: @identifier_schemes,
                       default_org: @user.org }
    end

    def update
      @user = User.find(params[:id])
      authorize @user
      # Replace the 'your' word from the canned responses so that it does
      # not read 'Successfully updated your profile for John Doe'
      topic = _("profile for %{username}") % { username: @user.name(false) }
      if @user.update_attributes(user_params)
        flash.now[:notice] = success_message(@user, _("updated"))
      else
        flash.now[:alert] = failure_message(@user, _("update"))
      end
      render :edit
    end

    private
    def user_params
      params.require(:user).permit(:email, :firstname, :surname, :org_id,
                                   :language_id, :other_organisation)
    end

  end

end
