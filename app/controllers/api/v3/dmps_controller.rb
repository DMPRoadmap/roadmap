# frozen_string_literal: true

module Api
  module V3
    # Endpoints that proxy calls to the DMPHub for DMP ID management
    class DmpsController < BaseApiController
      # POST /api/v3/dmps/{:id}/register
      #        Register the DMP ID for the specified draft DMP
      def create
        dmp = Draft.find_by(draft_id: dmp_params[:draft_id][:identifier])
        render_error(errors: DraftsController::MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?
        render_error(errors: DraftsController::MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless dmp.user&.org_id == current_user&.org_id

        dmp.metadata = _handle_dataset_distributions(dmp: dmp.metadata)
        result = dmp.register_dmp_id!
        render_error(errors: DraftsController::MSG_DMP_ID_REGISTRATION_FAILED, status: :bad_request) and return if result.nil?

        @items = paginate_response(results: [result])
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpsController.create #{e.message}"
        Rails.logger.error e.backtrace
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /api/v3/dmps
      def index
        dmps = DmpIdService.fetch_dmps(user: current_user)
        dmps = dmps.map { |dmp| _handle_contact_from_dmphub(dmp: dmp) }
        render_error(errors: DraftsController::MSG_DMP_NOT_FOUND, status: :not_found) and return unless dmps.is_a?(Array) &&
                                                                                                      dmps.any?
        # Remove any DMPs that the user has explicitly chosen to hide
        dmps = dmps.reject do |dmp|
          dmp_id = dmp.fetch('dmp_id', {})['identifier']
          dmp_id.nil? || current_user.hidden_dmps.pluck(:dmp_id).include?(dmp_id)
        end
        @items = paginate_response(results: dmps)
        render json: render_to_string(template: '/api/v3/drafts/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpsController.index #{e.message}"
        Rails.logger.error e.backtrace
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /api/v3/dmps/{:id}
      def show
        dmp = DmpIdService.fetch_dmp_id(dmp_id: params[:id])
        dmp = _handle_contact_from_dmphub(dmp: dmp)

        render_error(errors: DraftsController::MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?

        @items = paginate_response(results: [dmp])
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpsController.show #{e.message}"
        Rails.logger.error e.backtrace
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # PUT /api/v3/dmps/{:id}
      def update
        # TODO: In the new system, change this so it has its own endpoint!
        on_narrative_page = params[:id].end_with?('/narrative')
        dmp = on_narrative_page ? prep_for_narrative_update : prep_for_update
        dmp = _handle_contact_from_ui(dmp: dmp)
        dmp = _handle_dataset_distributions(dmp: dmp)
        render_error(errors: DraftsController::MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?

        authed = user_is_authorized(dmp: dmp.fetch('dmp', {}))
        render_error(errors: DraftsController::MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless authed

        result = DmpIdService.update_dmp_id(plan: dmp)
        render_error(errors: DraftsController::MSG_DMP_ID_UPDATE_FAILED, status: :bad_request) and return if result.nil?

        # If they updated a DMP that was created via the normal DMPTool create plan workflow, then we need to backfill
        # the updates
        dmp_id = dmp.fetch('dmp', dmp).fetch('dmp_id', {})['identifier']
        plan = Plan.find_by(dmp_id: dmp_id)
        _backfill_updates_to_plan(plan: plan, dmp: dmp) unless plan.nil?

        @items = paginate_response(results: [dmp])
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue JSON::ParserError => e
        Rails.logger.error "Failure in Api::V3::DmpsController.register_dmp_id #{e.message}"
        render_error(errors: MSG_INVALID_DMP_ID, status: 400)
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpsController.update #{e.message}"
        Rails.logger.error e.backtrace
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # DELETE /api/v3/dmps/{:id}
      def destroy
        dmp = DmpIdService.fetch_dmp_id(dmp_id: dmp_params.fetch(:dmp_id, {})[:identifier])
        render_error(errors: DraftsController::MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?
        render_error(errors: MSG_SERVER_ERROR, status: 500) unless dmp[:dmp_id][:identifier].present?

        authed = user_is_authorized(dmp: dmp.fetch('dmp', {}))
        render_error(errors: DraftsController::MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless authed

        # For now a user can only hide a DMP from their dashboard
        # result = DmpIdService.delete_dmp_id(plan: json)
        # render_error(errors: DmpsController::MSG_DMP_ID_TOMBSTONE_FAILED, status: :bad_request) and return if result.nil?
        HiddenDmp.find_or_create_by(user: current_user, dmp_id: dmp[:dmp_id][:identifier])

        @items = paginate_response(results: ['The DMP has been hidden for this user.'])
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpsController.destroy #{e.message}"
        Rails.logger.error e.backtrace
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      private

      def dmp_params
        params.require(:dmp).permit(:narrative, :remove_narrative, dmp_permitted_params, draft_data: {})
      end

      def update_narrative_params
        params.permit(:title, :narrative, :remove_narrative)
      end

      # Check to make sure the current user is authorized to update/tombstone the DMP ID
      def user_is_authorized(dmp:)
        return false unless dmp.is_a?(Hash) && dmp['contact'].present? && current_user.present? && current_user.can_org_admin?

        current_org = current_user.org&.identifier_for_scheme(scheme: 'ror')&.value
        orgs = [dmp.fetch('contact', {}).fetch('dmproadmap_affiliation', {}).fetch('affiliation_id', {})['identifier']]
        dmp.fetch('contributor', []).each do |contrib|
          orgs << contrib.fetch('dmproadmap_affiliation', {}).fetch('affiliation_id', {})['identifier']
        end
        orgs = orgs.map { |ror| ror.to_s.downcase.strip }.flatten.compact.uniq
        original_draft = Draft.find_by(dmp_id: dmp.fetch('dmp_id', {})['identifier'])

        # The admin is an Admin for one of the Orgs identified on the DMP record
        # OR they were the original creator of the draft
        orgs.include?(current_org) || (original_draft.present? && current_user.id == original_draft.user_id)
      end

      # process an update for the DMP's metadata
      def prep_for_update
        dmp_id = dmp_params.fetch('dmp_id', {})['identifier']
        dmp = DmpIdService.fetch_dmp_id(dmp_id: dmp_id)
        dmp.present? ? JSON.parse({ dmp: dmp_params.to_h }.to_json) : nil
      end

      # Process an update from the DMP Upload form's page that allows the narrative document to be uploaded
      # We need to handle differently because its multipart form data
      def prep_for_narrative_update
        # Fetch the draft and update it's narrative doc
        dmp_id = params[:id].gsub('/narrative', '').gsub('_', '/')
        draft = Draft.find_by(dmp_id: "https://#{dmp_id}")
        args = update_narrative_params

        # Remove the old narrative if applicable
        draft.narrative.purge if (args[:narrative].present? || args[:remove_narrative].present?) &&
                                  draft.narrative.attached?

        # Attach the narrative PDF if applicable
        draft.narrative.attach(args[:narrative]) if args[:narrative].present?
        draft.publish_narrative! if args[:narrative].present?

        # Then fetch the actual DMP record. The narrative will get moved to the DMPHub automatically
        dmp = DmpIdService.fetch_dmp_id(dmp_id: dmp_id)
        dmp['dmp']['title'] = args[:title] unless args[:title].nil?

        # If the user purged the old narrative remove it from the DMP ID record
        if args[:remove_narrative].present?
          works = dmp['dmp'].fetch('dmproadmap_related_identifiers', []).reject do |related|
            related['descriptor'] == 'is_metadata_for' && related['work_type'] == 'output_management_plan'
          end
          dmp['dmp']['dmproadmap_related_identifiers'] = works
        end
        dmp
      end

      # The DMP-ID actually stores the contact in a separate location, so transform it into a contributor
      # since that's what the React page currently works with!
      def _handle_contact_from_dmphub(dmp:)
        contact = dmp['dmp']['contact']
        return dmp if contact.nil?

        # Find the matching contributor entry
        contributors = dmp['dmp'].fetch('contributor', [])
        contrib = contributors.select do |hash|
          (!contact['contact_id'].nil? && hash['contributor_id'] == contact['contact_id']) ||
          (!contact['mbox'].nil? && hash['mbox'] == contact['mbox']) ||
          (!contact['name'].nil? && hash['name'] == contact['mbox'])
        end

        # If a match was found mark it as the primary contact
        contrib.first['contact'] = true unless contrib.empty?
        return dmp unless contrib.empty?

        # Otherwise add the contact to the contributor array
        dmp['dmp']['contributor'] = [] if dmp['dmp']['contributor'].nil?
        dmp['dmp']['contributor'] << JSON.parse({
          contact: true,
          name: contact['name'],
          mbox: contact['mbox'],
          contributor_id: contact['contact_id'],
          dmproadmap_affiliation: contact['dmproadmap_affiliation'],
          role: ['data_curation']
        }.to_json)
        dmp
      end

      # Transform a DMP from the React UI so that the contact is properly handled
      def _handle_contact_from_ui(dmp:)

pp dmp
p "INITIAL DMP:"
pp dmp['dmp']['contact']
pp dmp['dmp']['contributor']

        contact = dmp['dmp'].fetch('contributor', []).select { |h| !h['contact'].to_s&.downcase&.strip == 'true' }.first

p "CONTACT FOUND IN CONTRIBUTOR:"
pp contact

        return dmp if contact.nil?

        dmp['dmp']['contact'] = {
          name: contact['name'],
          mbox: contact['mbox'],
          contact_id: contact['contributor_id'],
          dmproadmap_affiliation: contact['dmproadmap_affiliation']
        }

p "AFTER SETTING CONTACT:"
pp dmp['dmp']['contact']
pp dmp['dmp']['contributor']

a = b / 0

        dmp
      end

      def _handle_dataset_distributions(dmp:)
        # hack to fix issue in React client for dataset.distribution coming through as a Hash instead of an Array :/
        dmp['dmp']['dataset'] = dmp['dmp'].fetch('dataset', []).map do |entry|
          return entry if entry['distribution'].nil? || !entry['distribution'].is_a?(Hash)

          entry['distribution'] = entry['distribution'].values
          entry
        end
        dmp
      end

      # Back changes made to a DMP ID to the original Plan
      def _backfill_updates_to_plan(plan:, dmp:)
        return false unless plan.is_a?(Plan) && dmp.is_a?(Hash) && dmp['dmp'].is_a?(Hash)

        hash = dmp['dmp']
        project = hash.fetch('project', []).first
        funding = project.fetch('funding', []).first
        funder = Org.find_by(name: funding['name']) unless funding.nil?
        grant = funding.fetch('grant_id', {})['identifier']

        # Handle the DMP, Project and Funder info
        plan.title = hash.fetch('title', project.nil? ? nil : project['description'])
        plan.description = hash.fetch('description', project.nil? ? nil : project['description'])
        plan.start_date = project.nil? ? nil : project['start']
        plan.end_date = project.nil? ? nil : project['end']
        plan.funder_id = funder&.id
        plan.identifier = funding.nil? ? nil : funding['dmproadmap_opportunity_number']
        plan.grant = grant.nil? ? nil : Identifier.new(value: grant) unless plan.grant.present? && plan.grant.value == grant

        # Handle the contributors
        plan = _backfill_updates_to_contributors(plan: plan, contributors_in: hash.fetch('contributor', []))

        # Handle research outputs
        plan = _backfill_updates_to_outputs(plan: plan, outputs_in: hash.fetch('dataset', []))

        # Handle related works
        identifiers = hash.fetch('dmproadmap_related_identifier', [])
        plan.save(touch: false)
      end

      # Clear the Plan's existing contributors and then replace with the ones from the UI
      def _backfill_updates_to_contributors(plan:, contributors_in:)
        # Delete any existing contributors if the array is empty
        return plan.contributors.clear if !contributors_in.is_a?(Array) || contributors_in.empty?

        orcid = IdentifierScheme.find_by(name: 'orcid')

        # Loop through and add or update the ones from the incoming hash
        contribs = contributors_in.map do |hash|
          id = hash.fetch('contributor_id', {})['identifier']
          ror = hash.fetch('dmproadmap_affiliation', {}).fetch('affiliation_id', {})['identifier']
          org_name = hash.fetch('dmproadmap_affiliation', {})['name']
          org = RegistryOrg.find_by(ror_id: ror)&.org if ror.present?
          org = Org.find_or_create_by(name: name) if org.nil? && org_name.present?
          roles = hash.fetch('role', []).map do |role|
            role.start_with?('http') ? role.gsub(Contributor::ONTOLOGY_BASE_URL, '')&.downcase : role
          end

          contrib = Contributor.new(name: hash['name'], email: hash['mbox'], org: org)
          roles.each { |role| contrib.send(:"#{role.gsub('-', '_')}=", true) }
          contrib.identifiers << Identifier.new(value: id, identifier_scheme: orcid) if id.present?
          contrib
        end

        plan.contributors.clear
        contribs.each { |contrib| plan.contributors << contrib }
        plan
      end

      def _backfill_updates_to_outputs(plan:, outputs_in:)
        research_outputs = outputs_in.map do |hash|
          distros = hash.fetch('distribution', [])
          hosts = distros.map { |distro| distro.fetch('host', []) }.flatten.uniq
          license = License.find_by(uri: distros.first.fetch('license', {})['license_ref']) if distros.any?
          byte_size = distros.first['byte_size']
          access = distros.first.fetch('data_access', 'open')

          repositories = hosts.map do |host|
            uri = host.fetch('dmproadmap_host_id', {})['identifier']
            repo = Repository.find_by(uri: uri) unless uri.nil?
            repo.present? ? repo : (!host['url'].nil? ? nil : Repository.find_by(homepage: host['url']))
          end

          standards = hash.fetch('metadata', []).map do |hash|
            uri = hash.fetch('metadata_standard_id', {})['identifier']
            standard = MetadataStandard.find_by(uri: uri) if uri.present?
            standard.present? ? standard : MetadataStandard.find_by(title: hash['description'])
          end

          output = ResearchOutput.new(title: hash['title'], description: hash['description'], release_date: hash['issued'],
                                      license: license, byte_size: byte_size, access: access,
                                      research_output_type: hash['type'],
                                      personal_data: hash['personal_data'] == 'yes',
                                      sensitive_data: hash['sensitive_data'] == 'yes')

          repositories.each { |repo| output.repositories << repo }
          standards.each { |standard| output.metadata_standards << standard }
          output
        end

        plan.research_outputs.clear
        research_outputs.each { |output| plan.research_outputs << output }
        plan
      end

    end
  end
end
