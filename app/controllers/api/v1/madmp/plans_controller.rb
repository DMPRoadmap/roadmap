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

        def import
          json_data = JSON.parse(request.raw_post)
          import_format = params[:import_format]
          template = Template.default
          Plan.transaction do
            plan = Plan.new
            errs = Import::PlanImportService.validate(json_data, import_format)
            render_error(errors: errs, status: :bad_request) and return if errs.any?

            json_data = Import::Converters::RdaToStandard.convert(json_data['dmp']) if import_format.eql?('rda')

            # Try to determine the Plan's owner
            owner = determine_owner(client: client, dmp: json_data)
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

            plan.title = format(_('%<user_name>s Plan'), user_name: "#{owner.firstname}'s")

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
        end

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
                           org: org }, User.first) # invite! needs a User, put the SuperAdmin as the inviter
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
