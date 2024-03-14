# frozen_string_literal: true

module Api
  module V3
    # Endpoints for Draft DMPs
    class DraftsController < BaseApiController
      MSG_DMP_ID_REGISTRATION_FAILED = 'Unable to register a DMP ID at this time.'
      MSG_DMP_ID_TOMBSTONE_FAILED = 'Unable to tombstone this DMP ID.'
      MSG_DMP_ID_UPDATE_FAILED = 'Unable to update the DMP ID metadata.'
      MSG_INVALID_DMP_ID = 'Invalid DMP ID, expected JSON data.'
      MSG_DMP_NOT_FOUND = 'DMP not found.'
      MSG_DMP_UNAUTHORIZED = 'Not authorized to modify the DMP.'

      # GET /drafts
      def index
        records = Draft.includes(narrative_attachment: [:blob])
                       .search(user: current_user, params: index_params)

                       # Paginate the results
        @drafts = paginate_response(results: process_sort(records: records.to_a))
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DraftsController.index #{e.message}"
        Rails.logger.error e.backtrace
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # POST /drafts
      def create
        # Extract the narrative PDF so we can add it to ActiveStorage
        args = create_params
        args.delete(:narrative)
        dmp = Draft.new(user: current_user, metadata: { dmp: args })

        # Attach the narrative PDF if applicable
        dmp.narrative.attach(create_params[:narrative]) if create_params[:narrative].present?
        if dmp.save
          @drafts = [dmp]
          render json: render_to_string(template: '/api/v3/drafts/index'), status: :created
        else
          render_error(errors: dmp.errors.full_messages, status: :bad_request)
        end
      rescue ActionController::ParameterMissing => e
        render_error(errors: "Invalid request #{Draft::INVALID_JSON_MSG}", status: :bad_request)
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DraftsController.create #{e.message}"
        Rails.logger.error e.backtrace
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /drafts/{:id}
      def show
        dmp = Draft.find_by(draft_id: params[:id])
        render_error(errors: MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?
        render_error(errors: MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless dmp.user&.org_id == current_user&.org_id

        @drafts = [dmp]
        render json: render_to_string(template: '/api/v3/drafts/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DraftsController.show #{e.message}"
        Rails.logger.error e.backtrace
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # PUT /drafts/{:id}
      def update
        dmp = Draft.find_by(draft_id: params[:id])
        render_error(errors: MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?
        render_error(errors: MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless dmp.user&.org_id == current_user&.org_id

        # Extract the narrative PDF so we can add it to ActiveStorage
        args = dmp_params
        args.delete(:narrative)

        # Attach the narrative PDF if applicable
        dmp.narrative.attach(dmp_params[:narrative]) if dmp_params[:narrative].present?

        if dmp.update(metadata: { dmp: args })
          @drafts = [dmp]
          render json: render_to_string(template: '/api/v3/drafts/index'), status: :ok
        else
          render_error(errors: dmp.errors.full_messages, status: :bad_request)
        end
      rescue ActionController::ParameterMissing => e
        render_error(errors: "Invalid request #{Draft::INVALID_JSON_MSG}", status: :bad_request)
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DraftsController.update #{e.message}"
        Rails.logger.error e.backtrace
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # DELETE /drafts/{:id}
      def destroy
        dmp = Draft.find_by(draft_id: params[:id])
        render_error(errors: MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?
        render_error(errors: MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless dmp.user&.org_id == current_user&.org_id

        # Narrative PDF will be automatically removed
        if dmp.destroy
          @drafts = []
          render json: render_to_string(template: '/api/v3/drafts/index'), status: :ok
        else
          render_error(errors: dmp.errors.full_messages, status: :bad_request)
        end
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DraftsController.destroy #{e.message}"
        Rails.logger.error e.backtrace
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # PUT /drafts/{:id}/narrative
      def update_narrative
        # Extract the narrative PDF so we can add it to ActiveStorage
        dmp = Draft.find_by(draft_id: params[:id])
        dmp = Draft.find_by(dmp_id: params[:id]) if dmp.nil?
        render_error(errors: MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?
        render_error(errors: MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless dmp.user&.org_id == current_user&.org_id

        # Remove the old narrative if applicable
        dmp.narrative.purge if (create_params[:narrative].present? || create_params[:remove_narrative].present?) &&
                               dmp.narrative.attached?

        # Attach the narrative PDF if applicable
        dmp.metadata.fetch('dmp', {})['title'] = create_params[:title] if create_params[:title].present?
        dmp.narrative.attach(create_params[:narrative]) if create_params[:narrative].present?
        if dmp.save
          @drafts = [dmp]
          render json: render_to_string(template: '/api/v3/drafts/index'), status: :ok
        else
          render_error(errors: dmp.errors.full_messages, status: :bad_request)
        end
      rescue ActionController::ParameterMissing => e
        render_error(errors: "Invalid request #{Draft::INVALID_JSON_MSG}", status: :bad_request)
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DraftsController.update_narrative #{e.message}"
        Rails.logger.error e.backtrace
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      private

      # Create params come through as multipart/form-data and I'm having trouble getting the top level :dmp to work
      # so we have specific params for the create action
      def create_params
        params.permit(:title, :narrative, :remove_narrative)
      end

      def dmp_params
        params.require(:dmp).permit(:narrative, :remove_narrative, dmp_permitted_params, draft_data: {})
      end

      def index_params
        params.permit(:title, :funder, :grant_id, :visibility, :dmp_id, :sort, :sort_dir)
      end

      def process_sort(records:)
        return records unless records.is_a?(Array)

        # Process sort
        sort_col = %w[project funder modified].include?(index_params[:sort]&.downcase&.strip) ? index_params[:sort] : 'modified'
        sort_dir = index_params[:sort_dir].upcase if %w[asc desc].include?(index_params[:sort_dir]&.downcase&.strip)
        sort_dir = sort_col == 'modified' ? 'desc' : 'asc' if sort_dir.nil?

        records.sort do |a, b|
          case sort_col
          when 'project'
            a_val = a.metadata['dmp'].fetch('project', [{}])&.first&.fetch('name', '')
            b_val = b.metadata['dmp'].fetch('project', [{}])&.first&.fetch('name', '')
          when 'funder'
            a_val = a.metadata['dmp'].fetch('project', [{}])&.first&.fetch('funding', [{}])&.first&.fetch('name', '')
            b_val = b.metadata['dmp'].fetch('project', [{}])&.first&.fetch('funding', [{}])&.first&.fetch('name', '')
          else
            a_val = a.metadata['dmp'].fetch('modified', '')
            b_val = b.metadata['dmp'].fetch('modified', '')
          end

          # Safety check here to prevent comparison failures
          a_val = '' if a_val.nil?
          b_val = '' if b_val.nil?

          sort_dir == 'asc' ? a_val <=> b_val : b_val <=> a_val
        end
      end

      # Convert the ActiveRecord results into JSON
      def plans_to_drafts(plans:)
        return plans unless plans.respond_to?(:any?) && plans.any?

        jsons = plans.map do |plan|
          json = render_to_string(partial: '/api/v2/plans/show', locals: { plan: plan })
          metadata = JSON.parse({ dmp: JSON.parse(json) }.to_json)
          Draft.new(metadata: metadata, dmp_id: plan.dmp_id)
        end
      end
    end
  end
end
