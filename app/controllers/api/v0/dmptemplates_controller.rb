module Api
  module V0
    class DmptemplatesController < Api::V0::BaseController
      before_action :authenticate


      ##
      # GET
      # @return a list of templates ordered by organisation
      def index
        # check if the user has permissions to use the templates API
        if has_auth(constant("api_endpoint_types.templates"))
          @all_templates = Dmptemplate.all
          respond_with @all_templates
        else
          #render unauthorised
          render json: I18n.t("api.no_auth_for_endpoint"), status: 401
        end

      end
    end
  end
end