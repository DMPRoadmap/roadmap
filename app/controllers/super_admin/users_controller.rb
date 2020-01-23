# frozen_string_literal: true

module SuperAdmin

  class UsersController < ApplicationController

    after_action :verify_authorized

    def edit
      @user = User.find(params[:id])
      authorize @user
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      render "super_admin/users/edit",
             locals: { user: @user,
                       departments: @departments,
                       plans: @plans,
                       languages: @languages,
                       orgs: @orgs,
                       identifier_schemes: @identifier_schemes,
                       default_org: @user.org }
    end

    def update
      @user = User.find(params[:id])
      authorize @user
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      # Replace the 'your' word from the canned responses so that it does
      # not read 'Successfully updated your profile for John Doe'
      topic = _("profile for %{username}") % { username: @user.name(false) }

      org_hash = params[:user][:org_id]
      user_params.delete(:org_id)
      user_params.delete(:org_name)
      user_params.delete(:org_crosswalk)

      if @user.update_attributes(user_params)
        # Handle the Org selection and attach the user to it
        org = params_to_org!(org_id: org_hash)

        if org.present? && org.id != @user.org.id
          org.save if org.new_record?

          ids = OrgSelection::HashToOrgService.to_identifiers(
            hash: JSON.parse(params[:user][:org_id])
          )
          org.save_identifiers!(array: ids)

          @user.update(org_id: org.id)
        end

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
        remove: remove.name(false), keep: @user.name(false)})
      if @user.merge(remove)
        flash.now[:notice] = success_message(@user, _("merged"))
      else
        flash.now[:alert] = failure_message(@user, _("merge"))
      end
      # After merge attempt get departments and plans
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      render :edit
    end

    def search
      @user = User.find(params[:id])
      @users = User.where('email LIKE ?', "%#{params[:email]}%")
      authorize @users
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
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
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      if @user.archive
        flash.now[:notice] = success_message(@user, _("archived"))
      else
        flash.now[:alert] = failure_message(@user, _("archive"))
      end
      render :edit
    end

    private
    def user_params
      params.require(:user).permit(:email,
                                   :firstname,
                                   :surname,
                                   :org_id, :org_name, :org_crosswalk,
                                   :department_id,
                                   :language_id,
                                   :other_organisation)
    end

    # Finds or creates the selected org and then returns it's id
    def params_to_org!(org_id:)
      return nil unless org_id.present? && org_id.is_a?(String)

      json = JSON.parse(org_id).with_indifferent_access
      OrgSelection::HashToOrgService.to_org(hash: json)

    rescue JSON::ParserError => pe
      log.error "Unable to parse org_id param from RegistrationsController:"
      log.error "  #{pe.message} :: org_id hash: #{org_id.inspect}"
      nil
    end

  end

end
