# frozen_string_literal: true

module Api
  module V1
    module Madmp
      # Handles CRUD operations for MadmpSchemas in API V1
      class PlansController < BaseApiController
        respond_to :json
        include MadmpExportHelper

        # GET /api/v1/madmp/plans/:id
        # rubocop:disable Metrics/AbcSize
        def show
          plan = Plan.find(params[:id])
          plan_fragment = plan.json_fragment
          selected_research_outputs = query_params[:research_outputs]&.map(&:to_i) || plan.research_output_ids
          # check if the user has permissions to use the API
          unless Api::V1::Madmp::PlansPolicy.new(client, plan).show?
            render_error(errors: 'Unauthorized to access plan', status: :unauthorized)
            return
          end

          respond_to do |format|
            format.json
            render 'shared/export/madmp_export_templates/default/plan', locals: {
              dmp: plan_fragment, selected_research_outputs: selected_research_outputs
            }
            return
          end
        rescue ActiveRecord::RecordNotFound
          render_error(errors: [_('Plan not found')], status: :not_found)
        end
        # rubocop:enable Metrics/AbcSize

        # GET /api/v1/madmp/plans/:id/rda_export
        # rubocop:disable Metrics/AbcSize
        def rda_export
          plan = Plan.find(params[:id])
          plan_fragment = plan.json_fragment
          selected_research_outputs = query_params[:research_outputs]&.map(&:to_i) || plan.research_output_ids
          # check if the user has permissions to use the API
          unless Api::V1::Madmp::PlansPolicy.new(client, plan).rda_export?
            render_error(errors: 'Unauthorized to access plan', status: :unauthorized)
            return
          end

          respond_to do |format|
            format.json
            render 'shared/export/madmp_export_templates/rda/plan', locals: {
              dmp: plan_fragment, selected_research_outputs: selected_research_outputs
            }
            return
          end
        rescue ActiveRecord::RecordNotFound
          render_error(errors: [_('Plan not found')], status: :not_found)
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
