# frozen_string_literal: true

class Api::V0::BaseController < ApplicationController

  protect_from_forgery with: :null_session
  before_action :define_resource, only: %i[destroy show update]
  respond_to :json

  # POST /api/{plural_resource_name}
  def create
    define_resource(resource_class.new(resource_params))

    if retrieve_resource.save
      render :show, status: :created
    else
      render json: retrieve_resource.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/{plural_resource_name}/1
  def destroy
    retrieve_resource.destroy
    head :no_content
  end

  # GET /api/{plural_resource_name}
  def index
    plural_resource_name = "@#{resource_name.pluralize}"
    resources = resource_class.where(query_params)
                              .page(page_params[:page])
                              .per(page_params[:page_size])

    instance_variable_set(plural_resource_name, resources)
    respond_with instance_variable_get(plural_resource_name)
  end

  # GET /api/{plural_resource_name}/1
  def show
    respond_with retrieve_resource
  end

  # PATCH/PUT /api/{plural_resource_name}/1
  def update
    if retrieve_resource.update(resource_params)
      render :show
    else
      render json: retrieve_resource.errors, status: :unprocessable_entity
    end
  end

  private

  # The resource from the created instance variable
  #
  # Returns Object
  def retrieve_resource
    instance_variable_get("@#{resource_name}")
  end

  # The allowed parameters for searching. Override this method in each API
  # controller to permit additional parameters to search on
  #
  # Returns Hash
  def query_params
    {}
  end

  # The allowed parameters for pagination
  #
  # Returns Hash
  def page_params
    params.permit(:page, :page_size)
  end

  # The resource class based on the controller
  #
  # Returns Object
  def resource_class
    @resource_class ||= resource_name.classify.constantize
  end

  # The singular name for the resource class based on the controller
  #
  # Returns String
  def resource_name
    @resource_name ||= controller_name.singularize
  end

  # Only allow a trusted parameter "white list" through.
  # If a single resource is loaded for #create or #update,
  # then the controller for the resource must implement
  # the method "#{resource_name}_params" to limit permitted
  # parameters for the individual model.
  def resource_params
    @resource_params ||= send("#{resource_name}_params")
  end

  # Use callbacks to share common setup or constraints between actions.
  def define_resource(resource = nil)
    resource ||= resource_class.find(params[:id])
    instance_variable_set("@#{resource_name}", resource)
  end

  def authenticate
    authenticate_token || render_bad_credentials
  end

  def authenticate_token
    authenticate_with_http_token do |token, _options|
      # reject the empty string as it is our base empty token
      if token != ""
        @token = token
        @user = User.find_by(api_token: token)
        # if no user found, return false, otherwise true
        !@user.nil? && @user.can_use_api?
      else
        false
      end
    end
  end

  def render_bad_credentials
    headers["WWW-Authenticate"] = "Token realm=\"\""
    render json: _("Bad Credentials"), status: 401
  end

end
