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

    def merge
      @user = User.find(params[:id])
      authorize @user
      remove = User.find(params[:merge_id])
      topic = _("profile for %{remove} into %{keep}" % {
        remove: remove.name(false)}, keep: @user.name(false))
      if @user.merge(remove)
        flash.now[:notice] = success_message(@user, _("merged"))
      else
        flash.now[:alert] = failure_message(@user, _("merge"))
      end
      render :edit
    end

    def search
      @user = User.find(params[:id])
      @users = User.where('email LIKE ?', "%#{params[:email]}%")
      authorize @users
      # WHAT TO RETURN!?!?!
      if @users.present? # found a user, or Users, submit for merge
        render json: {
          form: render_to_string(partial: 'super_admin/users/confirm_merge.html.erb'),
        }
      else  # NO USER, re-render w/error?
        flash.now[:alert] = "Unable to find user"
        render :edit # re-do as responding w/ json
      end
    end

    def archive
      @user  = User.find(params[:id])
      authorize @user
      if @user.archive
        flash.now[:notice] = success_message(@user, _("archived"))
      else
        flash.now[:alert] = failure_message(@user, _("archive"))
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
