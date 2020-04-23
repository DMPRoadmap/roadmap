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

  def users
    unless Api::V0::DepartmentsPolicy.new(@user, nil).users?
      raise Pundit::NotAuthorizedError
    end
    @users = @user.org.users.includes(:department)
  end

  def assign_users
    @department = Department.find(params[:id])

    unless Api::V0::DepartmentsPolicy.new(@user, @department).assign_users?
      raise Pundit::NotAuthorizedError
    end

    emails = params[:users]
    #puts emails
    emails.each do |email|
      user = User.find_by(email: email)
      # Currently the validation is that the user's org matches the api users
      # Not sure if this could/should be captured in Pundit
      unless @user.present? && @user.org == user&.org
        raise Pundit::NotAuthorizedError, _("user #{email} was not found on your organisation")
      end

      user.department = @department
      user.save!
      puts user.email
      puts user.department
    end
    redirect_to users_api_v0_departments_path
  end


  private



end
