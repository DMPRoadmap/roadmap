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
    org.links = { org: [] } if org.links.blank?
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
    attrs[:logo] = (attrs[:logo].presence || @org.logo)
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
    end

    # DMPTool customization: Verify default values
    attrs = ensure_api_email_content(attrs: attrs)
    if @org.update(attrs)
      # Save any identifiers that were found
      if current_user.can_super_admin? && identifiers.present?
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

  # GET /orgs/shibboleth_ds/:id
  # POST /orgs/shibboleth_ds/:id
  def shibboleth_ds_passthru
    # This action is used ONLY if Rails.configuration.x.shibboleth.use_filtered_discovery_service
    # is true! It will attempt to redirect the user to the Rails.configuration.x.shibboleth.login_url
    # you have defined with the Org's entity_id (editable in the Super Admin's 'Edit Org' page)
    skip_authorization

    org = process_org!(user: current_user, managed_only: true)

    if org.present?
      entity_id = org.identifier_for_scheme(scheme: 'shibboleth')

      if entity_id.present? && entity_id.value.present?

        Rails.logger.debug { "REDIRECTING TO IDP: #{shib_login_url}?#{shib_callback_url}&entityID=#{entity_id.value}" }

        # initiate shibboleth login sequence
        redirect_to "#{shib_login_url}?#{shib_callback_url}&entityID=#{entity_id.value}"
      else
        # The Org has no entity_id for Shib so redirect them to the branded sign in page
        @user = User.new(org: org)
        render 'shared/authentication/org_branded_access_controls'
      end
    else

      # If we are using our own Shibboleth Service Provider SP then we need the entity_id so fail
      redirect_to after_sign_in_error_path_for(User.new),
                  alert: _('Please choose an institution from the list.')
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def org_params
    params.require(:org)
          .permit(:name, :abbreviation, :logo, :target_url, :contact_email, :contact_name,
                  :remove_logo, :managed, :feedback_enabled, :org_links,
                  :funder, :institution, :organisation,
                  :feedback_msg, :org_id, :org_name, :org_crosswalk,
                  :api_create_plan_email_subject, :api_create_plan_email_body, :helpdesk_email,
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
    Rails.configuration.x.shibboleth.login_url
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

  # DMPTool cusotmization to prevent API creation email values from being NULL
  def ensure_api_email_content(attrs:)
    unless attrs[:api_create_plan_email_subject].present?
      attrs[:api_create_plan_email_subject] =
        Org.default_create_plan_api_subject
    end
    unless attrs[:api_create_plan_email_body].present?
      attrs[:api_create_plan_email_body] =
        Org.default_create_plan_api_body
    end
    attrs
  end
end
