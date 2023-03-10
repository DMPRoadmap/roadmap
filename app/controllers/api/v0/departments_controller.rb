# frozen_string_literal: true

module Api
  module V0
    # Handles CRUD operations for Departments in API V0
    class DepartmentsController < Api::V0::BaseController
      before_action :authenticate

      ##
      # Create a new department based on the information passed in JSON to the API
      def create
        raise Pundit::NotAuthorizedError unless Api::V0::DepartmentsPolicy.new(@user, nil).index?

        @department = Department.new(org: @user.org,
                                     code: params[:code],
                                     name: params[:name])
        if @department.save
          redirect_to api_v0_departments_path
        else
          # the department did not save
          headers['WWW-Authenticate'] = 'Token realm=""'
          render json: _('Departments code and name must be unique'), status: 400
        end
      end

      ##
      # Lists the departments for the API user's organisation
      def index
        raise Pundit::NotAuthorizedError unless Api::V0::DepartmentsPolicy.new(@user, nil).index?

        @departments = @user.org.departments
      end

      ##
      # List the users for each department on the organisation
      def users
        raise Pundit::NotAuthorizedError unless Api::V0::DepartmentsPolicy.new(@user, nil).users?

        @users = @user.org.users.includes(:department)
      end

      ##
      # Assign the list of users to the passed department id
      def assign_users
        @department = Department.find(params[:id])

        raise Pundit::NotAuthorizedError unless Api::V0::DepartmentsPolicy.new(@user, @department).assign_users?

        assign_users_to(@department.id)

        @users = @user.org.users.includes(:department)
        render users_api_v0_departments_path
      end

      ##
      # Remove departments from the list of users
      def unassign_users
        @department = Department.find(params[:id])

        raise Pundit::NotAuthorizedError unless Api::V0::DepartmentsPolicy.new(@user, @department).assign_users?

        assign_users_to(nil)

        @users = @user.org.users.includes(:department)
        render users_api_v0_departments_path
      end

      private

      def assign_users_to(department_id)
        params[:users].each do |email|
          reassign = User.find_by(email: email)
          # Currently the validation is that the user's org matches the API user's
          # Not sure if this is possible to capture in pundit
          unless @user.present? && @user.org == reassign&.org
            raise Pundit::NotAuthorizedError, _("user #{email} was not found on your organisation")
          end

          reassign.department_id = department_id
          reassign.save!
        end
      end
    end
  end
end
