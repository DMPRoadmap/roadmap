# frozen_string_literal: true

class Api::V0::DepartmentsController < Api::V0::BaseController

  before_action :authenticate

  ##
  # Create a new department based on the information passed in JSON to the API
  def create
    unless Api::V0::DepartmentsPolicy.new(@user, nil).index?
      raise Pundit::NotAuthorizedError
    end
    @department = Department.new(org: @user.org,
                                 code: params[:code],
                                 name: params[:name])
    if @department.save
      redirect_to api_v0_departments_path
    else
      # the department did not save
      self.headers["WWW-Authenticate"] = "Token realm=\"\""
      render json: _("Departments code and name must be unique"), status: 400
    end
  end

  ##
  # Lists the departments for the API user's organisation
  def index
    unless Api::V0::DepartmentsPolicy.new(@user, nil).index?
      raise Pundit::NotAuthorizedError
    end
    @departments = @user.org.departments
  end

  ##
  # List the users for each department on the organisation
  def users
    unless Api::V0::DepartmentsPolicy.new(@user, nil).users?
      raise Pundit::NotAuthorizedError
    end
    @users = @user.org.users.includes(:department)
  end

  ##
  # Assign the list of users to the passed department id
  def assign_users
    @department = Department.find(params[:id])

    unless Api::V0::DepartmentsPolicy.new(@user, @department).assign_users?
      raise Pundit::NotAuthorizedError
    end

    assign_users_to(@department.id)
    redirect_to users_api_v0_departments_path
  end

  ##
  # Remove departments from the list of users
  def unassign_users
    unless Api::V0::DepartmentsPolicy.new(@user, @department).assign_users?
      raise Pudndit::NotAuthorizedError
    end

    assign_users_to(nil)
    redirect_to users_api_v0_departments_path
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
      reasign.save!
    end
  end

end
