# frozen_string_literal: true

# Controller for Org pages for Admins
class OrgsController < ApplicationController
  include OrgSelectable

  after_action :verify_authorized, except: %w[
    shibboleth_ds shibboleth_ds_passthru search
  ]
  respond_to :html

  # TODO: Refactor this one along with super_admin/orgs_controller. Consider moving
  #       to a new `admin` namespace, leaving public facing actions in here and
  #       moving all of the `admin_` ones to the `admin` namespaced controller

  # TODO: Just use instance variables instead of passing locals. Separating the
  #       create/update will make that easier.
  # GET /org/admin/:id/admin_edit
  def admin_edit
    org = Org.find(params[:id])
    authorize org
    languages = Language.all.order('name')
    org.links = { org: [] } unless org.links.present?
    render 'admin_edit', locals: { org: org, languages: languages, method: 'PUT',
                                   url: admin_update_org_path(org) }
  end

  # PUT /org/admin/:id/admin_update
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def admin_update
    attrs = org_params
    @org = Org.find(params[:id])
    authorize @org

    # If a new logo was supplied then use it, otherwise retain the existing one
    attrs[:logo] = attrs[:logo].present? ? attrs[:logo] : @org.logo
    # Remove the logo if the user checked the box
    attrs[:logo] = nil if attrs[:remove_logo] == '1'

    tab = (attrs[:feedback_enabled].present? ? 'feedback' : 'profile')
    @org.links = ActiveSupport::JSON.decode(params[:org_links]) if params[:org_links].present?

    # Only allow super admins to change the org types and shib info
    if current_user.can_super_admin?
      identifiers = []
      attrs[:managed] = attrs[:managed] == '1'

      # Handle Shibboleth identifier if that is enabled
      if Rails.configuration.x.shibboleth.use_filtered_discovery_service
        shib = IdentifierScheme.by_name('shibboleth').first

        if shib.present? && attrs[:identifiers_attributes].present?
          key = attrs[:identifiers_attributes].keys.first
          entity_id = attrs[:identifiers_attributes][:"#{key}"][:value]
          # rubocop:disable Metrics/BlockNesting
          if entity_id.present?
            identifier = Identifier.find_or_initialize_by(
              identifiable: @org, identifier_scheme: shib, value: entity_id
            )
            @org = process_identifier_change(org: @org, identifier: identifier)
          else
            # The user blanked out the entityID so delete the record
            @org.identifier_for_scheme(scheme: shib)&.destroy
          end
          # rubocop:enable Metrics/BlockNesting
        end
        attrs.delete(:identifiers_attributes)
      end

      # See if the user selected a new Org via the Org Lookup and
      # convert it into an Org
      lookup = org_from_params(params_in: attrs)
      ids = identifiers_from_params(params_in: attrs)
      identifiers += ids.select { |id| id.value.present? }
    end

    # Remove the extraneous Org Selector hidden fields
    attrs = remove_org_selection_params(params_in: attrs)

    if @org.update(attrs)
      # Save any identifiers that were found
      if current_user.can_super_admin? && lookup.present?
        # Loop through the identifiers and then replace the existing
        # identifier and save the new one
        identifiers.each do |id|
          @org = process_identifier_change(org: @org, identifier: id)
        end
        @org.save
      end
      redirect_to "#{admin_edit_org_path(@org)}##{tab}",
                  notice: success_message(@org, _('saved'))
    else
      failure = failure_message(@org, _('save')) if failure.blank?
      redirect_to "#{admin_edit_org_path(@org)}##{tab}", alert: failure
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # This action is used by installations that have the following config enabled:
  #   Rails.configuration.x.shibboleth.use_filtered_discovery_service
  # rubocop:disable Metrics/AbcSize
  def shibboleth_ds
    unless current_user.nil?
      redirect_to root_path
      return
    end

    @user = User.new
    # Display the custom Shibboleth discovery service page.
    @orgs = Identifier.by_scheme_name('shibboleth', 'Org')
                      .sort { |a, b| a.identifiable.name <=> b.identifiable.name }
                      .map(&:identifiable)

    # Disabling the rubocop check here because it would not be clear what happens
    # if the ``@orgs` array has items ... it renders the shibboleth_ds view
    # rubocop:disable Style/GuardClause, Style/RedundantReturn
    if @orgs.empty?
      flash.now[:alert] = _('No organisations are currently registered.')
      redirect_to user_shibboleth_omniauth_authorize_path
      return
    end
    # rubocop:enable Style/GuardClause, Style/RedundantReturn
  end

  # This action is used to redirect a user to the Shibboleth IdP
  # POST /orgs/shibboleth_ds
  def shibboleth_ds_passthru
    if shib_params[:org_id].blank?
      redirect_to shibboleth_ds_path, notice: _('Please choose an organisation')
    else
      session['org_id'] = shib_params[:org_id]

      org = Org.where(id: shib_params[:org_id])
      shib_entity = Identifier.by_scheme_name('shibboleth', 'Org')
                              .where(identifiable: org)

      if shib_entity.empty?
        failure = _('Your organisation does not seem to be properly configured.')
        redirect_to shibboleth_ds_path, alert: failure
      else
        # initiate shibboleth login sequence
        entity_param = "entityID=#{shib_entity.first.value}"
        redirect_to "#{shib_login_url}?#{shib_callback_url}&#{entity_param}"
      end

    end
  end
  # rubocop:enable Metrics/AbcSize

  # POST /orgs  (via AJAX from Org Typeaheads ... see below for specific pages)
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def search
    args = search_params
    # If the search term is greater than 2 characters
    if args.present? && args.fetch(:name, '').length > 2
      type = params.fetch(:type, 'local')

      # If we are including external API results
      orgs = case type
             when 'combined'
               # This type will search both ROR and the local DB giving the local
               # DB results preference. It is triggered from the following pages:
               #   Create Account
               #   Edit Profile
               #   Admin Edit User
               #   Contributor Edit/New
               #   Project Details (Funder selection)
               #
               # Those pages use the app/views/shared/org_selectors/_combined.html.erb
               OrgSelection::SearchService.search_combined(
                 search_term: args[:name]
               )
             when 'external'
               # This type will ONLY check ROR for the specified search term. It
               # is triggered from the following page:
               #  SuperAdmin - New Org
               #
               # That page uses the app/views/shared/org_selectors/_external_only.html.erb
               OrgSelection::SearchService.search_externally(
                 search_term: args[:name]
               )
             else
               # This default will ONLY check the local DB's Org table. It is
               # currently not triggered by any pages.
               OrgSelection::SearchService.search_locally(
                 search_term: args[:name]
               )
             end

      # Scenarios where we only allow the user to select from the Orgs in the
      # local DB use the app/views/shared/org_selectors/_local_only.html.erb
      # which is not AJAX. The page has the entire list of Orgs and so does not
      # call this #search action!
      # The following pages currently have this behavior:
      #  Create Plan page (both Research Org and Funder typeaheads)
      #  Templates page (SuperAdmin Org Affiliation change)

      # If we need to restrict the results to funding orgs then
      # only return the ones with a valid fundref
      if orgs.present? && params.fetch(:funder_only, 'false') == 'true'
        orgs = orgs.select do |org|
          org[:fundref].present? && !org[:fundref].blank?
        end
      end

      render json: orgs

    else
      render json: []
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  private

  def org_params
    params.require(:org)
          .permit(:name, :abbreviation, :logo, :contact_email, :contact_name,
                  :remove_logo, :managed, :feedback_enabled, :org_links,
                  :funder, :institution, :organisation,
                  :feedback_msg, :org_id, :org_name, :org_crosswalk,
                  :helpdesk_email,
                  identifiers_attributes: %i[identifier_scheme_id value],
                  tracker_attributes: %i[code id])
  end

  def shib_params
    params.permit('org_id')
  end

  def search_params
    params.require(:org).permit(:name, :type)
  end

  def shib_login_url
    shib_login = Rails.configuration.x.shibboleth.login_url
    "#{request.base_url.gsub('http:', 'https:')}#{shib_login}"
  end

  def shib_callback_url
    "target=#{user_shibboleth_omniauth_callback_url.gsub('http:', 'https:')}"
  end

  # Destroy the identifier if it exists and was blanked out, replace the
  # identifier if it was updated, create the identifier if its new, or
  # ignore it
  # rubocop:disable Metrics/AbcSize
  def process_identifier_change(org:, identifier:)
    return org unless identifier.is_a?(Identifier)

    if !identifier.new_record? && identifier.value.blank?
      # Remove the identifier if it has been blanked out
      identifier.destroy
    elsif identifier.value.present?
      # If the identifier already exists then remove it
      current = org.identifier_for_scheme(scheme: identifier.identifier_scheme)
      current.destroy if current.present? && current.value != identifier.value

      identifier.identifiable = org
      org.identifiers << identifier
    end

    org
  end
  # rubocop:enable Metrics/AbcSize
end
