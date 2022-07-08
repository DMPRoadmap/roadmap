# frozen_string_literal: true

module SuperAdmin
  # Controller for performing CRUD operations for other users
  class UsersController < ApplicationController
    include OrgSelectable

    after_action :verify_authorized

    # GET /super_admin/users/:id/edit
    def edit
      @user = User.find(params[:id])
      authorize @user
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      render 'super_admin/users/edit',
             locals: { user: @user,
                       departments: @departments,
                       plans: @plans,
                       languages: @languages,
                       orgs: @orgs,
                       identifier_schemes: @identifier_schemes,
                       default_org: @user.org }
    end

    # PUT /super_admin/users/:id
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def update
      @user = User.find(params[:id])
      authorize @user
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      # See if the user selected a new Org via the Org Lookup and
      # convert it into an Org
      attrs = user_params
      lookup = org_from_params(params_in: attrs)
      identifiers = identifiers_from_params(params_in: attrs)

      # Remove the extraneous Org Selector hidden fields
      attrs = remove_org_selection_params(params_in: attrs)

      if @user.update(attrs)
        # If its a new Org create it
        if lookup.present? && lookup.new_record?
          lookup.save
          identifiers.each do |identifier|
            identifier.identifiable = lookup
            identifier.save
          end
          lookup.reload
        end
        @user.update(org_id: lookup.id) if lookup.present?

        flash.now[:notice] = success_message(@user, _('updated'))
      else
        flash.now[:alert] = failure_message(@user, _('update'))
      end
      render :edit
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # PUT /super_admin/users/:id/merge
    # rubocop:disable Metrics/AbcSize
    def merge
      @user = User.find(params[:id])
      authorize @user

      if params[:id] == params[:merge_id]
        flash.now[:alert] = _("You attempted to merge 2 accounts with the same email address.
           Please merge with a different email address.")
      else
        merge_accounts
      end

      # After merge attempt get departments and plans
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)

      render :edit
    end
    # rubocop:enable Metrics/AbcSize

    # GET /super_admin/users/:id/search
    # rubocop:disable Metrics/AbcSize
    def search
      @user = User.find(params[:id])
      @users = User.where('email LIKE ?', "%#{params[:email]}%")
      authorize @users
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      # WHAT TO RETURN!?!?!
      if @users.present? # found a user, or Users, submit for merge
        render json: {
          form: render_to_string(partial: 'super_admin/users/confirm_merge.html.erb')
        }
      else # NO USER, re-render w/error?
        flash.now[:alert] = 'Unable to find user'
        render :edit # re-do as responding w/ json
      end
    end
    # rubocop:enable Metrics/AbcSize

    # PUT /super_admin/users/:id/archive
    # rubocop:disable Metrics/AbcSize
    def archive
      @user = User.find(params[:id])
      authorize @user
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      if @user.archive
        flash.now[:notice] = success_message(@user, _('archived'))
      else
        flash.now[:alert] = failure_message(@user, _('archive'))
      end
      render :edit
    end
    # rubocop:enable Metrics/AbcSize

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

    def merge_accounts
      remove = User.find(params[:merge_id])
      if @user.merge(remove)
        flash.now[:notice] = success_message(@user, _('merged'))
      else
        flash.now[:alert] = failure_message(@user, _('merge'))
      end
    end
  end
end
