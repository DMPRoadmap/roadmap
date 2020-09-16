# frozen_string_literal: true

class OrgsController < ApplicationController

  include OrgSelectable

  after_action :verify_authorized, except: %w[
    shibboleth_ds shibboleth_ds_passthru search
  ]
  respond_to :html

  ##
  # GET /organisations/1/edit
  def admin_edit
    org = Org.find(params[:id])
    authorize org
    languages = Language.all.order("name")
    org.links = { "org": [] } unless org.links.present?
    render "admin_edit", locals: { org: org, languages: languages, method: "PUT",
                                   url: admin_update_org_path(org) }
  end

  ##
  # PUT /organisations/1
  def admin_update
    attrs = org_params
    @org = Org.find(params[:id])
    authorize @org
    @org.logo = attrs[:logo] if attrs[:logo]
    tab = (attrs[:feedback_enabled].present? ? "feedback" : "profile")
    if params[:org_links].present?
      @org.links = JSON.parse(params[:org_links])
    end

    # Only allow super admins to change the org types and shib info
    if current_user.can_super_admin?
      identifiers = []
      attrs[:managed] = attrs[:managed] == "1"

      # Handle Shibboleth identifier if that is enabled
      if Rails.application.config.shibboleth_use_filtered_discovery_service
        shib = IdentifierScheme.by_name("shibboleth").first

        if shib.present? && attrs.fetch(:identifiers_attributes, {}).any?
          entity_id = attrs[:identifiers_attributes].first[1][:value]
          identifier = Identifier.find_or_initialize_by(
            identifiable: @org, identifier_scheme: shib, value: entity_id
          )
          @org = process_identifier_change(org: @org, identifier: identifier)
        end
        attrs.delete(:identifiers_attributes)
      end

      # See if the user selected a new Org via the Org Lookup and
      # convert it into an Org
      lookup = org_from_params(params_in: attrs)
      ids = identifiers_from_params(params_in: attrs)
      identifiers += ids.select { |id| id.value.present? }

      # Remove the extraneous Org Selector hidden fields
      attrs = remove_org_selection_params(params_in: attrs)
    end

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

      redirect_to "#{admin_edit_org_path(@org)}\##{tab}",
                  notice: success_message(@org, _("saved"))
    else
      failure = failure_message(@org, _("save")) if failure.blank?
      redirect_to "#{admin_edit_org_path(@org)}\##{tab}", alert: failure
    end
  end

  # GET /orgs/shibboleth_ds
  # ----------------------------------------------------------------
  def shibboleth_ds
    redirect_to root_path unless current_user.nil?

    @user = User.new
    # Display the custom Shibboleth discovery service page.
    @orgs = Identifier.by_scheme_name("shibboleth", "Org").order(:name)

    if @orgs.empty?
      flash.now[:alert] = _("No organisations are currently registered.")
      redirect_to user_shibboleth_omniauth_authorize_path
    end
  end

  # POST /orgs/shibboleth_ds
  # ----------------------------------------------------------------
  def shibboleth_ds_passthru
    if !params["shib-ds"][:org_name].blank?
      session["org_id"] = params["shib-ds"][:org_name]

      org = Org.where(id: params["shib-ds"][:org_id])
      shib_entity = Identifier.by_scheme_name("shibboleth", "Org")
                              .where(identifiable: org)

      if !shib_entity.empty?
        # Force SSL
        shib_login = Rails.application.config.shibboleth_login
        url = "#{request.base_url.gsub("http:", "https:")}#{shib_login}"
        target = "#{user_shibboleth_omniauth_callback_url.gsub('http:', 'https:')}"

        # initiate shibboleth login sequence
        redirect_to "#{url}?target=#{target}&entityID=#{shib_entity.first.value}"
      else
        failure = _("Your organisation does not seem to be properly configured.")
        redirect_to shibboleth_ds_path, alert: failure
      end

    else
      redirect_to shibboleth_ds_path, notice: _("Please choose an organisation")
    end
  end

  # POST /orgs/search  (via AJAX)
  # ----------------------------------------------------------------
  def search
    args = search_params
    # If the search term is greater than 2 characters
    if args.present? && args.fetch(:name, "").length > 2
      type = params.fetch(:type, "local")

      # If we are including external API results
      case type
      when "combined"
        orgs = OrgSelection::SearchService.search_combined(
          search_term: args[:name]
        )
      when "external"
        orgs = OrgSelection::SearchService.search_externally(
          search_term: args[:name]
        )
      else
        orgs = OrgSelection::SearchService.search_locally(
          search_term: args[:name]
        )
      end

      # If we need to restrict the results to funding orgs then
      # only return the ones with a valid fundref
      if orgs.present? && params.fetch(:funder_only, "false") == true
        orgs = orgs.select do |org|
          org[:fundref].present? && !org[:fundref].blank?
        end
      end

      render json: orgs

    else
      render json: []
    end
  end

  private

  def org_params
    params.require(:org)
          .permit(:name, :abbreviation, :logo, :contact_email, :contact_name,
                  :remove_logo, :org_type, :managed, :feedback_enabled,
                  :feedback_email_msg, :org_id, :org_name, :org_crosswalk,
                  identifiers_attributes: [:identifier_scheme_id, :value],
                  tracker_attributes: [:code])
  end

  def search_params
    params.require(:org).permit(:name, :type)
  end

  # Destroy the identifier if it exists and was blanked out, replace the
  # identifier if it was updated, create the identifier if its new, or
  # ignore it
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

end
