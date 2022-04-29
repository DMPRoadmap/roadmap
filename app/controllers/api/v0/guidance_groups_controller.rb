# frozen_string_literal: true

module Api
  module V0
    # Handles GuidanceGroup queries for API V0
    class GuidanceGroupsController < Api::V0::BaseController
      before_action :authenticate

      def index
        raise Pundit::NotAuthorizedError unless Api::V0::GuidanceGroupPolicy.new(@user, :guidance_group).index?

        @all_viewable_groups = GuidanceGroup.all_viewable(@user)
        respond_with @all_viewable_groups
      end

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
