# frozen_string_literal: true

module Api
  module V1
    module Madmp
      # Handles CRUD operations for MadmpSchemas in API V1
      class PlansController < BaseApiController
        respond_to :json
        include MadmpExportHelper
        include MadmpImportHelper
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

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def rda_import
          rda_dmp = params['dmp'].permit!
          @dmp = rda_to_default(rda_dmp)
          @dmp = @dmp.deep_stringify_keys
          @template = Template.default
          # Need to have an account already, admin mail meanwhile
          @plan_user = User.find_by(email: 'info-opidor@inist.fr')
          # ensure user exists
          if @plan_user.blank?
            User.invite!({ email: params[:plan][:email] }, @user)
            @plan_user = User.find_by(email: params[:plan][:email])
            @plan_user.org = @user.org
            @plan_user.save
          end
          @plan = Plan.new
          @plan.org_id = @plan_user.org.id
          @plan.template = @template
          @plan.title = @dmp['meta']['title']

          if @plan.save

            @plan.add_user!(@plan_user.id, :creator)
            @plan.create_plan_fragments
            @dmp_fragment = @plan.json_fragment
            @dmp_fragment.raw_import(@dmp.slice('meta', 'project'), MadmpSchema.find_by(name: 'DMPStandard'))

            research_outputs = @dmp['researchOutput']
            research_outputs.each do |element|
              begin
                max_order = @plan.research_outputs.maximum('order') + 1
              rescue StandardError
                max_order = 1
              end
              @created_research_output = @plan.research_outputs.create(
                abbreviation: "Research Output #{max_order}",
                title: element['researchOutputDescription']['title'],
                is_default: false,
                research_output_type_id: ResearchOutputType.find_by(label: 'Dataset').id,
                order: max_order
              )
              import_research_output(@created_research_output.json_fragment, element, @plan)
            end
            respond_with @plan
          else
            # the plan did not save
            headers['WWW-Authenticate'] = 'Token realm=""'
            render json: _('Bad Parameters'), status: 400
          end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        # POST /api/v1/madmp/plans/standard_import
        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def standard_import
          @dmp = params.permit!
          @template = Template.default
          @plan_user = User.find_by(email: @dmp['meta']['contact']['person']['mbox'])
          # ensure user exists
          if @plan_user.blank?
            # no plan in params
            User.invite!({ email: params[:plan][:email] }, @user)
            @plan_user = User.find_by(email: params[:plan][:email])
            @plan_user.org = @user.org
            @plan_user.save
          end
          @plan = Plan.new
          @plan.org_id = @plan_user.org.id
          @plan.template_id = @template.id
          @plan.title = params[:meta][:title]
          if @plan.save

            @plan.add_user!(@plan_user.id, :creator)
            @plan.create_plan_fragments
            @dmp_fragment = @plan.json_fragment
            @dmp_fragment.raw_import(@dmp.slice('meta', 'project'), MadmpSchema.find_by(name: 'DMPStandard'))

            research_outputs = @dmp['researchOutput']
            research_outputs.each do |element|
              begin
                max_order = @plan.research_outputs.maximum('order') + 1
              rescue StandardError
                max_order = 1
              end
              @created_research_output = @plan.research_outputs.create(
                abbreviation: "Research Output #{max_order}",
                title: element['researchOutputDescription']['title'],
                is_default: false,
                order: max_order
              )
              import_research_output(@created_research_output.json_fragment, element, @plan)
            end
            respond_with @plan
          else
            # the plan did not save
            headers['WWW-Authenticate'] = 'Token realm=""'
            render json: _('Bad Parameters'), status: 400
          end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

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
