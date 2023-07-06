# frozen_string_literal: true

module Api
  module V1
    module Madmp
      # Handles CRUD operations for MadmpSchemas in API V1
      class PlansController < BaseApiController
        respond_to :json
        include MadmpExportHelper
        # GET /api/v1/madmp/plans/:id(/research_outputs/:uuid)
        # GET /api/v1/madmp/plans/research_outputs/:uuid
        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def show
          if params[:id].present?
            plan = Api::V1::PlansPolicy::Scope.new(client, Plan).resolve.find(params[:id])
            selected_research_outputs = plan.research_output_ids
          else
            plan = Plan.joins(:research_outputs)
                       .where(research_outputs: { uuid: params[:uuid] }).first
            plan.add_api_client!(client) if client.is_a?(ApiClient)
            selected_research_outputs = plan.research_outputs.where(uuid: params[:uuid]).pluck(:id)
          end

          plan_fragment = plan.json_fragment
          export_format = params[:export_format]
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
        rescue ActiveRecord::RecordNotFound
          render_error(errors: [_('Plan not found')], status: :not_found)
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def import
          json_data = JSON.parse(request.raw_post)
          import_format = params[:import_format]
          template = Template.default
          # rubocop:disable Metrics/BlockLength
          Plan.transaction do
            plan = Plan.new
            errs = Import::PlanImportService.validate(json_data, import_format)
            render_error(errors: errs, status: :bad_request) and return if errs.any?

            if import_format.eql?('rda')
              json_data = Import::Converters::RdaToStandardConverter.convert(json_data['dmp'])
            end

            # Try to determine the Plan's owner
            owner = determine_owner(client:, dmp: json_data)
            if owner.nil?
              render_error(
                errors: [_('Unable to determine owner of the DMP, please specify an existing user as the contact')],
                status: :bad_request
              )
              return
            end
            plan.org = owner.org if owner.present? && plan.org.blank?

            plan.visibility = Rails.configuration.x.plans.default_visibility
            plan.template = template

            plan.title = format(_('%{user_name} Plan'), user_name: "#{owner.firstname}'s")

            if plan.save
              plan.add_user!(owner.id, :creator)
              plan.create_plan_fragments

              Import::PlanImportService.import(plan, json_data, 'standard')

              respond_with plan
            else
              render_error(errors: [_('Invalid JSON')], status: :bad_request)
            end
          rescue JSON::ParserError
            render_error(errors: [_('Invalid JSON')], status: :bad_request)
          end
          # rubocop:enable Metrics/BlockLength
        end
        # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        private

        # Get the Plan's owner
        def determine_owner(client:, dmp:)
          if client.is_a?(User)
            client
          else
            contact = dmp.dig('meta', 'contact', 'person')
            user = User.find_by(email: contact['mbox'])
            return user if user.present?

            org = client.org || Org.find_by(name: 'PLEASE CHOOSE AN ORGANISATION IN YOUR PROFILE')
            User.invite!({ email: contact['mbox'],
                           firstname: contact['firstName'],
                           surname: contact['lastName'],
                           org: }, User.first) # invite! needs a User, put the SuperAdmin as the inviter
          end
        end

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
