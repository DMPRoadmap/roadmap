# frozen_string_literal: true

module Api

  module V1

    module Madmp

      class PlansController < BaseApiController

        respond_to :json
        include MadmpExportHelper

        # GET /api/v1/madmp/plans/:id
        def show
          begin
            plan = Plan.find(params[:id])
            plan_fragment = plan.json_fragment
            selected_research_outputs = query_params[:research_outputs]&.map(&:to_i) || plan.research_output_ids
            # check if the user has permissions to use the API
            unless Api::V1::Madmp::PlansPolicy.new(client, plan).show?
              render_error(errors: "Unauthorized to access plan", status: :unauthorized)
              return
            end

            respond_to do |format|
              format.json
              render "shared/export/madmp_export_templates/default/plan", locals: {
                dmp: plan_fragment, selected_research_outputs: selected_research_outputs
              }
              return
            end
          rescue ActiveRecord::RecordNotFound
            render_error(errors: [_("Plan not found")], status: :not_found)
          end
        end

        # GET /api/v1/madmp/plans/:id/rda_export
        def rda_export
          begin
            plan = Plan.find(params[:id])
            plan_fragment = plan.json_fragment
            selected_research_outputs = query_params[:research_outputs]&.map(&:to_i) || plan.research_output_ids
            # check if the user has permissions to use the API
            unless Api::V1::Madmp::PlansPolicy.new(client, plan).rda_export?
              render_error(errors: "Unauthorized to access plan", status: :unauthorized)
              return 
            end
        
            respond_to do |format|
              format.json
              render "shared/export/madmp_export_templates/rda/plan", locals: {
                dmp: plan_fragment, selected_research_outputs: selected_research_outputs
              }
              return
            end
          rescue ActiveRecord::RecordNotFound
            render_error(errors: [_("Plan not found")], status: :not_found)
          end
        end


        private

        def select_research_output(plan_fragment, selected_research_outputs)
          plan_fragment.data["researchOutput"] = plan_fragment.data["researchOutput"].select {
            |r| r == { "dbid" => research_output_id }
          }
          plan_fragment
        end

        def query_params
          params.permit(:mode, research_outputs: [])
        end

      end
    end
  end
end