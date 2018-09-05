module Api
  module V0
    class ThemesController < Api::V0::BaseController
      def extract
        @theme = Theme.find(extract_params[:id])
        @answers = @theme.answers

        extract_filtering_params.each do |key, value|
          @answers = @answers.public_send(key, value) if value
        end
      end

      def extract_params
        params.permit(:id, :plan_id, :question_id, :start_date, :end_date)
      end

      def extract_filtering_params
        extract_params.slice(:plan_id, :question_id, :start_date, :end_date)
      end
    end
  end
end
