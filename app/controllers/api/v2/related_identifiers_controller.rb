# frozen_string_literal: true

module Api

  module V2

    class RelatedIdentifiersController < BaseApiController

      respond_to :json

      # Ensure that the Client is able to perform the necessary operation
      before_action -> { doorkeeper_authorize!(:edit_dmps) }, only: %i[create]

      # POST /api/v2/related_identifiers
      # ------------------
      def create
        json = @json.with_indifferent_access.fetch(:dmp, {})
        render_error(errors: _("Invalid JSON!"), status: :bad_request) and return unless json.present?

        plan = Api::V2::DeserializationService.plan_from_dmp_id(dmp_id: json[:dmp_id])
        render_error(errors: _("Plan not found"), status: :not_found) and return unless plan.present?

        plan = Api::V2::PlansPolicy::Scope.new(@client, @resource_owner, nil).resolve
                                          .select { |p| p.id = plan.id }.first
        render_error(errors: _("Plan not found"), status: :not_found) and return unless plan.present?

        related_identifiers = json.fetch(:dmproadmap_related_identifiers, [])

        errs = Api::V2::JsonValidationService.related_identifiers_errors(
          json: related_identifiers
        )

        if errs.empty?
          RelatedIdentifier.transaction do
            related_identifiers.each do |related_identifier|
              id = Api::V2::Deserialization::RelatedIdentifier.deserialize(
                plan: plan, json: related_identifier
              )
              errs += id.errors.full_messages unless id.valid?
              next unless id.valid? && id.new_record?

              id.save
              # Record this API activity
              log_activity(subject: id, change_type: :added)
            end
          end
        end

        if errs.flatten.any?
          render_error(errors: errs.flatten.uniq, status: :bad_request)
        else
          @items = paginate_response(results: [plan.reload])
          render "/api/v2/plans/index", status: :created
        end

      rescue StandardError => e
        Rails.logger.error "API::V2::RelatedIdentifierController - create - #{e.message}"
        Rails.logger.error e.backtrace
        render_error(errors: "Unable to process the request at this time", status: 500)
      end

    end

  end

end
