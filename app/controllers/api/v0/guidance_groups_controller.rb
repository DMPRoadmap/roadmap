module Api
  module V0
    class GuidanceGroupsController  < Api::V0::BaseController
      before_action :authenticate

      def show
        # check if the user has permission to use the guidances api
        if has_auth(constant("api_endpoint_types.guidances"))
          # determine if they have authorization to view this guidance group
          if GuidanceGroup.can_view?(@user, params[:id])
            respond_with get_resource
          else
            render json: I18n.t("api.bad_resource"), status: 401
          end
        else
          render json: I18n.t("api.no_auth_for_endpoint"), status: 401
        end
      end

      def index
        if has_auth(constant("api_endpoint_types.guidances"))
          @all_viewable_groups = GuidanceGroup.all_viewable(@user)
          respond_with @all_viewable_groups
        else
          #render unauthorised
          render json: I18n.t("api.no_auth_for_endpoint"), status: 401
        end
      end


      private
        def query_params
          params.permit(:id)
        end

    end
  end
end
