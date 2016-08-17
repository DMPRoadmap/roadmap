module Api
  module V0
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :set_resource, only: [:destroy, :show, :update]
      respond_to :json

      public
      # POST /api/{plural_resource_name}
      def create
        set_resource(resource_class.new(resource_params))

        if get_resource.save
          render :show, status: :created
        else
          render json: get_resource.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/{plural_resource_name}/1
      def destroy
        get_resource.destroy
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
        respond_with get_resource
      end

      # PATCH/PUT /api/{plural_resource_name}/1
      def update
        if get_resource.update(resource_params)
          render :show
        else
          render json: get_resource.errors, status: :unprocessable_entity
        end
      end

      private
      # returns the resource from the created instance variable
      # @return [Object]
      def get_resource
        instance_variable_get("@#{resource_name}")
      end

      # Returns the allowed parameters for searching
      # Override this method in each API controller
      # to permit additional parameters to search on
      # @return [Hash]
      def query_params
        {}
      end

      # Returns the allowed parameters for pagination
      # @return [Hash]
      def page_params
        params.permit(:page, :page_size)
      end

      # The resource class based on the controller
      # @return [Class]
      def resource_class
        @resource_class ||= resource_name.classify.constantize
      end

      # The singular name for the resource class based on the controller
      # @return [String]
      def resource_name
        @resource_name ||= self.controller_name.singularize
      end

      # Only allow a trusted parameter "white list" through.
      # If a single resource is loaded for #create or #update,
      # then the controller for the resource must implement
      # the method "#{resource_name}_params" to limit permitted
      # parameters for the individual model.
      def resource_params
        @resource_params ||= self.send("#{resource_name}_params")
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_resource(resource = nil)
        resource ||= resource_class.find(params[:id])
        instance_variable_set("@#{resource_name}", resource)
      end

      def authenticate
        authenticate_token || render_bad_credentials
      end

      def authenticate_token
        authenticate_with_http_token do |token, options|
          # reject the empty string as it is our base empty token
          if token != ""
            @token = token
            @user = User.find_by(api_token: token)
            # if no user found, return false, otherwise true
            !@user.nil?
          else
            false
          end
        end
      end


      def render_bad_credentials
        self.headers['WWW-Authenticate'] = "Token realm=\"\""
        render json: I18n.t("api.bad_credentials"), status: 401
      end

      def has_auth (auth_type)
        auth = false
        # not sure if initial if is necissary, but it works with it there... refactor later?
        # if !TokenPermission.where(api_token: @token).nil?
        #   TokenPermission.where(api_token: @token).find_each do |permission|
        #     if permission.token_permission_type.token_type == auth_type
        #       auth = true
        #       logger.info "we have auth"
        #     end
        #   end
        # end
        OrgTokenPermission.where(organisation_id: @user.organisation_id).find_each do |org_token_permission|
          logger.debug "#{org_token_permission.token_permission_type.token_type}"
          if org_token_permission.token_permission_type.token_type == auth_type
            auth= true
          end
        end
        return auth
      end

    end
  end
end
