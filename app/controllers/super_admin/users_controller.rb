# frozen_string_literal: true

module SuperAdmin
  # Controller for performing CRUD operations for other users
  class UsersController < ApplicationController
    include OrgSelectable

    after_action :verify_authorized

    # GET /super_admin/users/:id/edit
    def edit
      @user = User.find(params[:id])
      authorize @user, :super_admin_edit?
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
    # rubocop:disable Metrics/AbcSize
    def update
      @user = User.find(params[:id])
      authorize @user, :super_admin_update?
      @plans = Plan.active(@user).page(1)
      # OrgSelectable resolves existing organizations and persists new ones,
      # including their identifiers, before returning the selected record.
      attrs = user_params
      lookup = org_from_params(params_in: attrs)
      attrs = remove_org_selection_params(params_in: attrs)
      attrs[:org_id] = lookup.id if lookup.present?

      if @user.update(attrs)
        flash.now[:notice] = success_message(@user, _('updated'))
      else
        flash.now[:alert] = failure_message(@user, _('update'))
      end
      @departments = @user.org.departments.order(:name)
      render :edit, status: @user.errors.any? ? :unprocessable_content : :ok
    end
    # rubocop:enable Metrics/AbcSize

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
          form: render_to_string(partial: 'confirm_merge')
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
