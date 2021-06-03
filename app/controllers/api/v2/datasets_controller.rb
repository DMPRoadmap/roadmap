# frozen_string_literal: true

module Api

  module V2

    class DatasetsController < BaseApiController

      respond_to :json

      # If the Resource Owner (aka User) is in the Doorkeeper AccessToken then it is an authorization_code
      # token and we need to ensure that the ApiClient is authorized for the relevant Scope
      before_action -> { doorkeeper_authorize!(:create_dmps) if @resource_owner.present? }, only: %i[create update]
      before_action :fetch_plan


      # POST /api/v2/plans/[:id]/datasets
      # ------------------
      def create
        datasets = @json.with_indifferent_access.fetch(:items, []).first.fetch(:dmp, {}).fetch(:dataset, [])

        # Do a pass through the raw JSON and check to make sure all required fields
        # were present. If not, return the specific errors
        errs = []

        datasets.each do |dataset_json|
          errs += Api::V2::JsonValidationService.dataset_validation_errors(json: dataset_json)
        end
        render_error(errors: errs.flatten.uniq, status: :bad_request) and return if errs.flatten.any?

        # Convert the JSON into a Plan and it's associations
        unless errs.any?
          datasets.each do |dataset_json|
            object = Api::V1::Deserialization::Dataset.deserialize(plan: @plan, json: dataset_json)
            @plan.research_outputs << object if object.is_a?(ResearchOutput) && object.new_record?
            @plan.related_identifiers << object if object.is_a?(RelatedIdentifier) && object.new_record?

            Plan.transaction do
              # If we cannot save for some reason then return an error
              if @plan.save
                render("/api/v2/datasets/show", status: :created) and return
              else
                # rubocop:disable Layout/LineLength
                errs += _("Unable to add the datasets to this DMP! %{specific_errors}") % {
                  specific_errors: @plan.errors.full_messages
                }
              end
            end
          end
        end

        if errs.flatten.any?
          render_error(errors: errs.flatten.uniq, status: :bad_request)
        else
          render_error(errors: _("Unable to process the request at this time."), status: :server_error)
        end
      end

      # PUT /api/v2/plans/[:plan_id]/datasets/[:id]
      # ------------------
      def update
        render_error(errors: "This API functionality has not yet been implemented.", status: :server_error) and return
      end

      private

      def fetch_plan
        @plan = Api::V2::PlansPolicy::Scope.new(@client, @resource_owner, nil).resolve
                                           .select { |plan| plan.id = params[:id] }.first
        return true if @plan.present?

        render_error(errors: _("Plan not found"), status: :not_found)
      end

    end

  end

end
