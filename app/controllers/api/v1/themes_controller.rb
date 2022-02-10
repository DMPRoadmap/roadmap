# frozen_string_literal: true

module Api

  module V1

    class ThemesController < BaseApiController

      respond_to :json

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def extract
        # check if the user has permissions to use the themes API
        @theme = Theme.find_by(slug: params[:slug])
        @user = client
        @answers = []
        if client.is_a?(User)
          if @theme
            @answers = @theme.answers.where(plan_id: @user.plans.pluck(:id))
            admin_answers = []
            org_answers = []

            if params[:admin_visible].present? && params[:admin_visible]
              admin_answers = @theme.answers.where(plan_id: @user.org.plans.administrator_visible)
            end

            if params[:org_visible].present? && params[:org_visible]
              org_answers = @theme.answers.where(plan_id: @user.org.plans.organisationally_visible)
            end

            if params[:template_id].present? && params[:template_id]
              @answers =  @answers.where(plan_id: @user.plans.where(template_id: params[:template_id]).pluck(:id))
            end

            if params[:question_id].present? && params[:question_id]
              @answers =  @answers.where(question_id: params[:question_id])
            end

            if params[:start_date].present? && params[:start_date]
              @answers =  @answers.where("answers.created_at >= ?", params[:start_date])
            end

            if params[:end_date].present? && params[:end_date]
              @answers =  @answers.where("answers.created_at <=?", params[:end_date])
            end

            @answers + org_answers + admin_answers

          else
            render json: _("Theme not found"), status: 404
          end
        else
          render json: _("API Client not authorized to used Themes API"), status: 403
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def extract_params
        params.permit(:slug, :template_id, :question_id, :start_date, :end_date, :admin_visible, :org_visible)
      end

      def extract_filtering_params
        extract_params.slice(:template_id, :question_id, :start_date, :end_date, :admin_visible, :org_visible)
      end

    end

  end

end
