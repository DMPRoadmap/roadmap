module Dmpopidor
  module Controllers
    module Orgs

      # CHANGE: ADDED BANNER TEXT
      def admin_update
        attrs = org_params
        @org = Org.find(params[:id])
        authorize @org
        @org.logo = attrs[:logo] if attrs[:logo]
        tab = (attrs[:feedback_enabled].present? ? "feedback" : "profile")
        if params[:org_links].present?
          @org.links = JSON.parse(params[:org_links])
        end
    
        @org.banner_text = attrs[:banner_text] if attrs[:banner_text]

        # Only allow super admins to change the org types and shib info
        if current_user.can_super_admin?
          # Handle Shibboleth identifiers if that is enabled
          if Rails.application.config.shibboleth_use_filtered_discovery_service
            shib = IdentifierScheme.find_by(name: "shibboleth")
            shib_settings = @org.org_identifiers.select do |ids|
              ids.identifier_scheme == shib
            end.first
    
            if params[:shib_id].blank? && shib_settings.present?
              # The user cleared the shib values so delete the object
              shib_settings.destroy
            else
              unless shib_settings.present?
                shib_settings = OrgIdentifier.new(org: @org, identifier_scheme: shib)
              end
              shib_settings.identifier = params[:shib_id]
              shib_settings.attrs = { domain: params[:shib_domain] }
              shib_settings.save
            end
          end
        end
    
        if @org.update_attributes(attrs)
          redirect_to "#{admin_edit_org_path(@org)}\##{tab}",
                      notice: success_message(@org, _("saved"))
        else
          failure = failure_message(@org, _("save")) if failure.blank?
          redirect_to "#{admin_edit_org_path(@org)}\##{tab}", alert: failure
        end
      end
    end
  end
end