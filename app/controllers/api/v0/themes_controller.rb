module Api
  module V0
    class ThemesController < Api::V0::BaseController
      before_action :authenticate
      
      def extract
        # check if the user has permissions to use the themes API
        @theme = Theme.find(params[:id])
        raise Pundit::NotAuthorizedError unless Api::V0::ThemePolicy.new(@user, @theme).extract?
        @answers = @theme.answers.where(plan_id: @user.plans.pluck(:id))
        admin_answers = []
        org_answers = []

        if params[:admin_visible].present? && params[:admin_visible]
          admin_answers =  @theme.answers.where(plan_id: @user.org.plans.privately_visible)
        end

        if params[:org_visible].present? && params[:org_visible]
          org_answers =  @theme.answers.where(plan_id: @user.org.plans.organisationally_visible)
        end

        if params[:template_id].present? && params[:template_id]
          @answers =  @answers.where(plan_id: @user.plans.where(template_id: params[:template_id]).pluck(:id))
        end

        if params[:question_id].present? && params[:question_id]
          @answers =  @answers.where(question_id: params[:question_id])
        end
        
        @answers +=  admin_answers + org_answers
      end

      def extract_params
        params.permit(:id, :template_id, :question_id, :start_date, :end_date, :admin_visible, :org_visible)
      end

      def extract_filtering_params
        extract_params.slice(:template_id, :question_id, :start_date, :end_date, :admin_visible, :org_visible)
      end
    end
  end
end
