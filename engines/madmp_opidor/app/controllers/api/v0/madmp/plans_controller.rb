# frozen_string_literal: true

module Api
  module V0
    module Madmp
      # Handles CRUD operations for Plans in API V0
      class PlansController < Api::V0::BaseController
        before_action :authenticate
        include MadmpExportHelper

        # rubocop:disable Metrics/AbcSize
        def show
          plan = Plan.find(params[:id])
          plan_fragment = plan.json_fragment
          selected_research_outputs = query_params[:research_outputs]&.map(&:to_i) || plan.research_output_ids
          # check if the user has permissions to use the API
          raise Pundit::NotAuthorizedError unless Api::V0::Madmp::PlanPolicy.new(@user, plan).show?

          respond_to do |format|
            format.json
            if export_format.eql?('rda')
              render 'shared/export/madmp_export_templates/rda/plan', locals: {
                dmp: plan_fragment, selected_research_outputs:
              }
            else
              render 'shared/export/madmp_export_templates/default/plan', locals: {
                dmp: plan_fragment, selected_research_outputs:
              }
            end
            return
          end
        end
        # rubocop:enable Metrics/AbcSize

        private

        def select_research_output(plan_fragment, _selected_research_outputs)
          plan_fragment.data['researchOutput'] = plan_fragment.data['researchOutput'].select do |r|
            r == { 'dbid' => research_output_id }
          end
          plan_fragment
        end

        def query_params
          params.permit(:mode, research_outputs: [])
        end
      end
    end
  end
end
