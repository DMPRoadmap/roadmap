module Dmpopidor
  module Controllers
    module Orgs

      # CHANGE: ADDED BANNER TEXT and ACTIVE
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

          # if active is false, unpublish all published tempaltes
          if params[:active] != "1"
            p @org.published_templates.update_all(published: false)
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


      def org_params
        params.require(:org).permit(:name, :abbreviation, :logo, :contact_email,
                                    :contact_name, :remove_logo, :org_type,
                                    :feedback_enabled, :feedback_email_msg, :banner_text, :active)
      end
    end
  end
end