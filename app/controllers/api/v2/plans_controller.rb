# frozen_string_literal: true

module Api
  module V2
    # Endpoints for Plan interactions
    class PlansController < BaseApiController
      include ::ConditionsHelper

      respond_to :json, :pdf

      # If the Resource Owner (aka User) is in the Doorkeeper AccessToken then it is an authorization_code
      # token and we need to ensure that the ApiClient is authorized for the relevant Scope
      before_action -> { doorkeeper_authorize!(:public, :read_dmps) }, only: %i[index]
      before_action -> { doorkeeper_authorize!(:read_dmps) }, only: %i[show]
      before_action -> { doorkeeper_authorize!(:create_dmps) }, only: %i[create]
      before_action -> { doorkeeper_authorize!(:edit_dmps) }, only: %i[update]

      # GET /api/v2/plans
      # -----------------
      # rubocop:disable Metrics/AbcSize
      def index
        # Scope here is not the Doorkeeper scope, its just to refine the results
        @scope = 'mine'
        @scope = params[:scope].to_s.downcase if %w[mine public both].include?(params[:scope].to_s.downcase)

        # If the User is part of the pilot project then include their DMP Upload Drafts
        plans = @client&.user&.org&.v5_pilot? ? Draft.by_org(org_id: @client&.user&.org_id) : []

        # See the Policy for details on what Plans are returned to the Caller based on the AccessToken
        plans += Api::V2::PlansPolicy::Scope.new(@client, @resource_owner, @scope).resolve

        if plans.present? && plans.any?
          plans = plans.sort { |a, b| b.updated_at <=> a.updated_at }
          @items = paginate_response(results: plans)
          @minimal = true
          render 'api/v2/plans/index', status: :ok
        else
          render_error(errors: _('No Plans found'), status: :not_found)
        end
      end
      # rubocop:enable Metrics/AbcSize

      # GET /api/v2/plans/:id
      # ---------------------
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def show
        # See the Policy for details on what Plans are returned to the Caller based on the AccessToken
        @plan = Api::V2::PlansPolicy::Scope.new(@client, @resource_owner, 'both').resolve
                                           .find { |plan| plan.id.to_s == params[:id] }

        # See if it's a Draft if the Plan was not found
        @plan = Draft.find_by(id: params[:id].gsub('d_', '')) if @plan.nil? &&
                                                                 @client&.user&.org&.v5_pilot?
        if @plan.present?
          respond_to do |format|
            format.pdf do
              prep_for_pdf

              render pdf: @file_name,
                     margin: @formatting[:margin],
                     footer: {
                       center: format(_('Created using %{application_name}. Last modified %{date}'),
                                      application_name: ApplicationService.application_name,
                                      date: l(@plan.updated_at.localtime.to_date,
                                              format: :readable)),
                       font_size: 8,
                       spacing: (Integer(@formatting[:margin][:bottom]) / 2) - 4,
                       right: '[page] of [topage]',
                       encoding: 'utf8'
                     }
            end

            format.json do
              @items = paginate_response(results: [@plan])
              render '/api/v2/plans/index', status: :ok
            end
          end
        else
          render_error(errors: _('Plan not found'), status: :not_found)
        end
      end
      # rubocop:enable Metrics/AbcSize

      # POST /api/v2/plans
      # ------------------
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def create
        dmp = @json.with_indifferent_access.fetch(:dmp, {})

        # Do a pass through the raw JSON and check to make sure all required fields
        # were present. If not, return the specific errors
        errs = Api::V2::JsonValidationService.validation_errors(json: dmp)
        render_error(errors: errs, status: :bad_request) and return if errs.any?

        # Convert the JSON into a Plan and it's associations
        plan = Api::V2::Deserialization::Plan.deserialize(json: dmp)

        if plan.present?
          save_err = _('Unable to create your DMP')
          exists_err = _('Plan already exists. Send an update instead.')
          # rubocop:disable Layout/LineLength
          no_org_err = _('Could not determine ownership of the DMP. The :affiliation you specified for the :contact could not be validated. You must use either a ROR id or a known name. Possible matches: %{list_of_names}')
          # rubocop:enable Layout/LineLength

          # Skip if this is an existing DMP
          render_error(errors: exists_err, status: :bad_request) and return unless plan.new_record?

          # Try to find the owner based on the :contact
          owner = determine_owner(plan: plan, json: dmp.fetch(:contact, {}))

          # Try to determine the Plan's org
          plan.org_id = owner&.org&.present? ? owner.org_id : client.owner&.org_id
          if plan.org_id.blank?
            matches = find_matching_orgs(
              plan: plan, json: dmp.fetch(:contact, {}).fetch(:affiliation, {})
            )
            no_org_err = format(no_org_err, list_of_names: matches.map { |m| "'#{m}'" }.join(', '))
            render_error(errors: no_org_err, status: :bad_request) and return if plan.org_id.blank?
          end

          # Validate the plan and it's associations and return errors with context
          # e.g. 'Contact affiliation name can't be blank' instead of 'name can't be blank'
          errs = Api::V2::ContextualErrorService.contextualize_errors(plan: plan)
          # The resulting plan (our its associations were invalid)
          render_error(errors: errs, status: :bad_request) and return if errs.any?

          # If we cannot save for some reason then return an error
          plan = Api::V2::PersistenceService.safe_save(plan: plan)
          render_error(errors: save_err, status: :internal_server_error) and return if plan.new_record?

          # If the plan was generated by an ApiClient then add a subscription for them
          dmp_id_to_subscription(plan: plan, id_json: dmp[:dmp_id]) if client.is_a?(ApiClient)

          # User the Owner if one was found otherwise invite the :contact
          owner = notify_owner(client: client, owner: owner, plan: plan)
          plan.add_user!(owner.id, :creator)

          # Record this API activity
          log_activity(subject: plan, change_type: :added)

          # Kaminari Pagination requires an ActiveRecord result set :/
          @items = paginate_response(results: Plan.where(id: plan.id))
          render '/api/v2/plans/index', status: :created
        else
          render_error(errors: _('Invalid JSON format!'), status: :bad_request)
        end
      rescue JSON::ParserError
        render_error(errors: _('Invalid JSON'), status: :bad_request)
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      private

      def dmp_params
        params.require(:dmp).permit(plan_permitted_params).to_h
      end

      def plan_exists?(json:)
        return false unless json.present? &&
                            json[:dmp_id].present? &&
                            json[:dmp_id][:identifier].present?

        scheme = IdentifierScheme.by_name(json[:dmp_id][:type]).first
        Identifier.where(value: json[:dmp_id][:identifier], identifier_scheme: scheme).any?
      end

      # Get the Plan's owner
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def determine_owner(plan:, json:)
        return nil unless plan.present? && json.is_a?(Hash) && json[:mbox].present?

        user = User.find_by(email: json[:mbox])
        return user if user.present?

        id_json = json.fetch(:contact_id, {})
        orcid = id_json[:identifier] if id_json[:type]&.downcase == 'orcid'
        identifier = Identifier.by_scheme_name('orcid', 'User').where(value: orcid) if orcid.present?
        return identifier.identifiable if identifier.present?

        names = json[:name]&.split || ['']
        firstname = names.length > 1 ? names.first : nil
        surname = names.length > 1 ? names.last : names.first

        # Try to deserialize the Org. If no Org exists, try to find it by the user's email domain
        org = Api::V2::Deserialization::Org.deserialize(json: json[:affiliation])
        org = Org.from_email_domain(email_domain: json[:mbox].split('@')&.last) if org.blank?
        org.save if org&.new_record?

        user = User.new(firstname: firstname, surname: surname, email: json[:mbox], org: org,
                        password: SecureRandom.uuid)
        return user if orcid.blank?

        scheme = IdentifierScheme.find_by(name: 'orcid')
        user.identifiers << Identifier.new(identifier_scheme: scheme, value: orcid)
        user
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # If the contact's org could not be determined, then fetch the matches to return to the
      # caller
      # rubocop:disable Metrics/AbcSize
      def find_matching_orgs(plan:, json:)
        return [] unless plan.present? && json.is_a?(Hash) && json[:name].present?

        name = json[:name].downcase.split('(').first
        matches = Org.where(managed: true).search(name)
        matches += RegistryOrg.search(name) unless Rails.configuration.x.application.restrict_orgs
        matches.any? ? matches.map(&:name) : []
      end
      # rubocop:enable Metrics/AbcSize

      # Send the owner an email to let them know about the new Plan
      def notify_owner(client:, owner:, plan:)
        if owner.new_record?
          # This essentially drops the initializer User (aka owner) and creates a new one
          # via the Devise invitation methods
          User.invite!(
            inviter: client,
            plan: plan,
            context: 'api',
            params: {
              email: owner.email,
              firstname: owner.firstname,
              surname: owner.surname,
              org_id: owner.org_id
            }
          )
        else
          UserMailer.new_plan_via_api(
            recipient: owner, plan: plan, api_client: client
          ).deliver_now
          owner
        end
      end

      # Convert the dmp_id into an identifier for the ApiClient if applicable
      def dmp_id_to_subscription(plan:, id_json:)
        return nil unless id_json.is_a?(Hash) && id_json[:type] == 'other' && @client.is_a?(ApiClient)

        val = id_json[:identifier] if id_json[:identifier].start_with?(@client.callback_uri || '')
        val = "#{@client.callback_uri}#{id_json[:identifier]}" if val.blank?

        subscription = Subscription.find_or_initialize_by(
          plan: plan,
          subscriber: @client,
          callback_uri: val
        )
        subscription.updates = true
        subscription.deletions = true
        subscription.save
      end

      # rubocop:disable Metrics/AbcSize
      def prep_for_pdf
        return false if @plan.blank?

        # We need to eager loadd the plan to make this more efficient
        @plan = Plan.includes(:org, :research_outputs, roles: [:user],
                                                       contributors: [:org, { identifiers: [:identifier_scheme] }],
                                                       identifiers: [:identifier_scheme])
                    .find_by(id: @plan.id)

        # Include everything by default
        @show_coversheet         = true
        @show_sections_questions = true
        @show_unanswered         = true
        @show_custom_sections    = true
        @show_research_outputs   = @plan.research_outputs.any?
        @public_plan             = @plan.publicly_visible?
        @formatting =

          @hash           = @plan.as_pdf(nil, @show_coversheet)
        @formatting     = @plan.settings(:export).formatting || @plan.template.settings(:export).formatting
        @selected_phase = @plan.phases.order('phases.updated_at DESC').first

        # limit the filename length to 100 chars. Windows systems have a MAX_PATH allowance
        # of 255 characters, so this should provide enough of the title to allow the user
        # to understand which DMP it is and still allow for the file to be saved to a deeply
        # nested directory
        @file_name = Zaru.sanitize!(@plan.title).strip.gsub(/\s+/, '_')[0, 100]
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
