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
          ResearchOutput.transaction do
            datasets.each do |dataset_json|
              object = Api::V2::Deserialization::Dataset.deserialize(plan: @plan, json: dataset_json)
              # This is a create endpoint so only allow inserts!
              next unless object.new_record?

              errs << object.errors.full_messages unless object.valid?
              object.plan = @plan if object.respond_to?(:plan_id) && object.plan_id.nil?
              object.save if object.valid?

              # Record this API activity
              log_activity(subject: object, change_type: :added)
            end
          end

          # If we cannot save for some reason then return an error
          if errs.empty?
            @items = [@plan.reload]
            render "/api/v2/plans/index", status: :created
          else
            # rubocop:disable Layout/LineLength
            errs += _("Unable to add the datasets to this DMP! %{specific_errors}")
            render_error(errors: errs.flatten.uniq, status: :bad_request)
          end
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
