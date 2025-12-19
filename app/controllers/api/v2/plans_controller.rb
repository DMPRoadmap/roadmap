# frozen_string_literal: true

module Api
  module V2
    class PlansController < BaseApiController # rubocop:todo Style/Documentation
      respond_to :json

      # GET /api/v2/plans/:id
      def show
        raise Pundit::NotAuthorizedError unless @scopes.include?('read')

        @plan = Plan.find_by(id: params[:id])

        raise Pundit::NotAuthorizedError unless @plan.present?

        plans_policy = PlansPolicy.new(@resource_owner, @plan)
        raise Pundit::NotAuthorizedError unless plans_policy.show?

        @items = [@plan]
        @question_and_answer = ActiveModel::Type::Boolean.new.cast(params[:question_and_answer])

        render '/api/v2/plans/index', status: :ok
      end

      # GET /api/v2/plans
      def index
        raise Pundit::NotAuthorizedError unless @scopes.include?('read')

        @plans = PlansPolicy::Scope.new(@resource_owner).resolve
        @items = paginate_response(results: @plans)
        @question_and_answer = ActiveModel::Type::Boolean.new.cast(params[:question_and_answer])

        render '/api/v2/plans/index', status: :ok
      end
    end
  end
end
