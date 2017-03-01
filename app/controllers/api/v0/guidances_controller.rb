module Api
  module V0
    class GuidancesController < Api::V0::BaseController
      before_action :authenticate
      #after_action :verify_authorized

      ##
      # returns the specified guidance
      def show
        @guidance = Guidance.find(params[:id])
        raise Pundit::NotAuthorizedError unless Api::V0::GuidancePolicy.new(@user, @guidance).show?
        respond_with get_resource
      end

      ##
      # returns all guidances viewable to a user
      def index
        authorize Guidance
        raise Pundit::NotAuthorizedError unless Api::V0::GuidancePolicy.new(@user, :guidance).index?
        respond_with @all_viewable_guidances
      end

      ##
      # defines the default pundit user (overwrites current_user)
      def pundit_user
        @user
      end


      private
        def query_params
          params.permit(:id)
        end
    end
  end
end
