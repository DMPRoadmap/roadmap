# frozen_string_literal: true

module OrgAdmin

  class UsersController < ApplicationController

    prepend Dmpopidor::OrgAdmin::UsersController

    after_action :verify_authorized

    # SEE MODULE
    def edit
      @user = User.find(params[:id])
      authorize @user
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      render "org_admin/users/edit",
             locals: { user: @user,
                       departments: @departments,
                       plans: @plans,
                       languages: @languages,
                       orgs: @orgs,
                       identifier_schemes: @identifier_schemes,
                       default_org: @user.org }
    end

    # SEE MODULE
    def update
      @user = User.find(params[:id])
      authorize @user
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      if @user.update_attributes(user_params)
        flash.now[:notice] = success_message(@user, _("updated"))
      else
        flash.now[:alert] = failure_message(@user, _("update"))
      end
      render :edit
    end

    # SEE MODULE
    def user_plans
      @user = User.find(params[:id])
      authorize @user
      @plans = Plan.active(@user).page(1)
      render "org_admin/users/plans"
    end

    private

    def user_params
      params.require(:user).permit(:department_id)
    end

  end

end
