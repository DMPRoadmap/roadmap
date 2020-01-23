# frozen_string_literal: true

class OrgsController < ApplicationController

  after_action :verify_authorized, except: ["shibboleth_ds", "shibboleth_ds_passthru"]
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
      # Handle Shibboleth identifiers if that is enabled
      if Rails.application.config.shibboleth_use_filtered_discovery_service
        shib = IdentifierScheme.by_name("shibboleth")
        shib_settings = @org.identifiers.by_scheme_name("shibboleth", "Org")

        if params[:shib_id].blank? && shib_settings.present?
          # The user cleared the shib values so delete the object
          shib_settings.destroy
        else
          if shib_settings.present?
            shib_settings.value = params[:shib_id]
            shib_settings.attrs = { domain: params[:shib_domain] }
            shib_settings.save
          else
            identifier = Identifier.new(
              identifier_scheme: shib,
              value: params[:shib_id],
              attrs: { domain: params[:shib_domain] },
              identifiable: @org
            )
          end
        end
      end
    end

    attrs[:managed] = attrs[:managed] == "1"
    if @org.update_attributes(attrs)
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

  private
  def org_params
    params.require(:org).permit(:name, :abbreviation, :logo, :contact_email,
                                :contact_name, :remove_logo, :org_type, :managed,
                                :feedback_enabled, :feedback_email_msg)
  end

end
