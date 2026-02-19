# frozen_string_literal: true

module Api
  module V2
    class PlansController < BaseApiController # rubocop:todo Style/Documentation
      respond_to :json
      before_action :set_complete_param, only: %i[show index]

      # GET /api/v2/plans/:id
      def show
        raise Pundit::NotAuthorizedError unless @scopes.include?('read')

        @plan = Plan.includes(roles: :user).find_by(id: params[:id])

        raise Pundit::NotAuthorizedError unless @plan.present?

        plans_policy = PlansPolicy.new(@resource_owner, @plan)
        raise Pundit::NotAuthorizedError unless plans_policy.show?

        @items = [@plan]
        render '/api/v2/plans/index', status: :ok
      end

      # GET /api/v2/plans
      def index
        raise Pundit::NotAuthorizedError unless @scopes.include?('read')

        @plans = PlansPolicy::Scope.new(@resource_owner).resolve
        @plans = @plans.includes(answers: { question: :section }) if @complete
        @items = paginate_response(results: @plans)
        render '/api/v2/plans/index', status: :ok
      end

      private

      # GET /api/v2/plans?complete=true and  /api/v2/plans/:id?complete=true
      def set_complete_param
        @complete = params[:complete].to_s.downcase == 'true'
      end
    end
  end
end
