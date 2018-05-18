module SuperAdmin
  class OrgsController < ApplicationController
    after_action :verify_authorized

    def index
      authorize Org
      render 'index', locals: { orgs: Org.includes(:templates, :users) }
    end
    
    def new
      org = Org.new
      authorize org
      org.links = {"org": []}
      render 'orgs/admin_edit', locals: {org: org, languages: Language.all.order("name"), 
                                         method: 'POST', url: super_admin_orgs_path }
    end
    
    def create
      authorize Org
      org = Org.new(org_params)
      org.logo = params[:logo] if params[:logo]
      if params[:org_links].present?
        org.links = JSON.parse(params[:org_links]) 
      else
        org.links = { org: [] }
      end
    
      begin
        org.funder = params[:funder].present?
        org.institution = params[:institution].present?
        org.organisation = params[:organisation].present?      
    
        # Handle Shibboleth identifiers if that is enabled
        if Rails.application.config.shibboleth_use_filtered_discovery_service 
          shib = IdentifierScheme.find_by(name: 'shibboleth')

          if params[:shib_id].present? || params[:shib_domain].present?
            org.org_identifiers << OrgIdentifier.new(
              identifier_scheme: shib,
              identifier: params[:shib_id],
              attrs: {domain: params[:shib_domain]}.to_json.to_s
            )
          end
        end
      
        if org.save
          redirect_to admin_edit_org_path(org.id), notice: success_message(_('organisation'), _('created'))
        else
          flash[:alert] = failed_create_error(org, _('organisation'))
          render 'orgs/admin_edit', locals: {org: org, languages: Language.all.order("name"), 
                                             method: 'POST', url: super_admin_orgs_path }
        end
      rescue Dragonfly::Job::Fetch::NotFound => dflye
        redirect_to admin_edit_org_path(org), alert: _('There seems to be a problem with your logo. Please upload it again.')
        render 'orgs/admin_edit', locals: {org: org, languages: Language.all.order("name"), 
                                           method: 'POST', url: super_admin_orgs_path }
      end
    end
    
    def destroy
      org = Org.includes(:users, :templates, :guidance_groups).find(params[:id])
      authorize org
      
      # Only allow the delete if the org has no dependencies
      unless org.users.length > 0 || org.templates.length > 0
        org.guidance_groups.delete_all

        if org.destroy!
          redirect_to super_admin_orgs_path, notice: success_message(_('organisation'), _('removed'))
        else
          redirect_to super_admin_orgs_path, alert: failed_destroy_error(org, _('organisation'))
        end
      end
    end
    
    private
      def org_params
        params.require(:org).permit(:name, :abbreviation, :logo, :contact_email, :contact_name, :remove_logo,
                                    :feedback_enabled, :feedback_email_subject, :feedback_email_msg)
      end
    
  end
end