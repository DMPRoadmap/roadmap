module OrgAdmin
  class TemplatesController < ApplicationController
    include Paginable
    include Versionable
    include TemplateFilter
    after_action :verify_authorized

    # GET /org_admin/templates
    # -----------------------------------------------------
    def index
      authorize Template
      
# TODO: Refactor this method and its views in next sprint if time allows so that
#       we are no longer passing around hashes and do not need the template_filter.rb

      # Apply scoping
      all_templates_hash = apply_scoping(params[:scope] || 'all', false, true)
      own_hash = apply_scoping(params[:scope] || 'all', false, false)
      customizable_hash = apply_scoping(params[:scope] || 'all', true, false)

      # Apply pagination
      all_templates_hash[:templates] = all_templates_hash[:templates].page(1)
      own_hash[:templates] = own_hash[:templates].page(1)
      customizable_hash[:templates] = customizable_hash[:templates].page(1)

      # Gather up all of the publication dates for the live versions of each template.
      published = get_publication_dates(all_templates_hash[:scopes][:family_ids])
      
      render 'index', locals: {
        all_templates: all_templates_hash[:templates],
        customizable_templates: customizable_hash[:templates], 
        own_templates: own_hash[:templates],
        customized_templates: customizable_hash[:customizations],
        published: published,
        current_org: current_user.org, 
        orgs: Org.all,
        current_tab: params[:r],
        scopes: { all: all_templates_hash[:scopes], orgs: own_hash[:scopes], funders: customizable_hash[:scopes] }
      }
    end
    
    # GET /org_admin/templates/[:id]
    def show
      template = Template.includes(:org, :phases).find(params[:id])
      authorize template
      render 'container', locals: { partial_path: 'show', template: template }
    end
    
    # GET /org_admin/templates/:id/edit
    # -----------------------------------------------------
    def edit
      template = Template.includes(:org, :phases).find(params[:id])
      authorize template
      if !template.latest?
        flash[:notice] = _("You are viewing a historical version of this #{template_type(template)}. You will not be able to make changes.")
      end
      render 'container', locals: { partial_path: 'edit', template: template }
    end
    
    # GET /org_admin/templates/new
    # -----------------------------------------------------
    def new
      authorize Template
      render 'container', locals: { partial_path: 'new', template: Template.new(org: current_user.org) }
    end
    
    # POST /org_admin/templates
    # -----------------------------------------------------
    def create
      authorize Template
      # creates a new template with version 0 and new family_id
      template = Template.new(params[:template])
      template.org_id = current_user.org.id
      template.description = params['template-desc']
      template.links = (params["template-links"].present? ? JSON.parse(params["template-links"]) : {"funder": [], "sample_plan": []})

      if template.save!
        redirect_to edit_org_admin_template_path(template), notice: success_message(template_type(template), _('created'))
      else
# TODO: update view so we no longer need to use a hash
        hash = template.to_hash
        flash[:alert] = failed_create_error(template, template_type(template))
        render partial: "org_admin/templates/new", locals: { template: template, hash: hash }
      end
    end
    
    # PUT /org_admin/templates/:id (AJAXable)
    # -----------------------------------------------------
    def update
      template = Template.find(params[:id])
      authorize template   # NOTE if non-authorized error is raised, it performs a redirect to root_path and no JSON output is generated

      begin
        template = Template.find_or_generate_version!(template)
        template.links = ActiveSupport::JSON.decode(params["template-links"]) if params["template-links"].present?
        template.description = params["template-desc"]
      rescue ActiveSupport::JSON.parse_error
        render(status: :bad_request, json: { msg: _("Error parsing links for a #{template_type(template)}") }) and return
      rescue => e
        render(status: :forbidden, json: { msg: e.message }) and return
      end

      if template.update_attributes(params[:template])
        render(status: :ok, json: { msg: success_message(template_type(template), _('saved'))})
      else
        # Note failed_update_error may return HTML tags (e.g. <br/>) and therefore the client should parse them accordingly
        render(status: :bad_request, json: { msg: failed_update_error(template, template_type(template))})
      end
    end
    
    # DELETE /org_admin/templates/:id
    # -----------------------------------------------------
    def destroy
      template = Template.find(params[:id])
      current_tab = params[:r] || 'all-templates'
      authorize template

      if template.plans.length <= 0
        current = Template.current(template.family_id)

        # Only allow the current version to be destroyed
        if template.latest?
          if template.destroy
            flash[:notice] = success_message(template_type(template), _('removed'))
            redirect_to org_admin_templates_path(r: current_tab)
          else
            hash = template.to_hash
            flash[:alert] = failed_destroy_error(template, template_type(template))
            redirect_to org_admin_templates_path(r: current_tab)
          end
        else
          flash[:alert] = _("You cannot delete historical versions of this #{template_type(template)}.")
          redirect_to org_admin_templates_path(r: current_tab)
        end
      else
        flash[:alert] = _("You cannot delete a #{template_type(template)} that has been used to create plans.")
        redirect_to org_admin_templates_path(r: current_tab)
      end
    end

    # GET /org_admin/templates/:id/history
    # -----------------------------------------------------
    def history
      template = Template.find(params[:id])
      authorize template
      templates = Template.where(family_id: template.family_id)
      current = Template.current(template.family_id)
      current_tab = params[:r] || 'all-templates'
      render 'org_admin/templates/history', 
             locals: { templates: templates, template: template, current: current, current_tab: current_tab }
    end
    
    # POST /org_admin/templates/:id/customize
    # -----------------------------------------------------
    def customize
      template = Template.find(params[:id])
      authorize template
      current_tab = 'funder-templates'
      if template.customize?(current_user.org)
        begin
          customisation = template.customize!(current_user.org)
          redirect_to edit_org_admin_template_path(customisation, r: current_tab)
        rescue StandardError => e
          flash[:alert] = _('Unable to customize that template.')
          redirect_to org_admin_templates_path(r: current_tab)
        end
      else
        flash[:notice] = _('That template is not customizable.')
        redirect_to org_admin_templates_path(r: current_tab)
      end
    end

    # POST /org_admin/templates/:id/transfer_customization
    # the funder template's id is passed through here
    # -----------------------------------------------------
    def transfer_customization
      template = Template.includes(:org).find(params[:id])
      current_tab = 'funder-templates'
      authorize template
      if template.customize?(current_user.org)
        begin
          new_customization = template.upgrade_customization!
          redirect_to edit_org_admin_template_path(new_customization, r: current_tab)
        rescue StandardError => e
          flash[:alert] = _('Unable to transfer your customizations.')
          redirect_to org_admin_templates_path(r: current_tab)
        end
      else
        flash[:notice] = _('That template is no longer customizable.')
        redirect_to org_admin_templates_path(r: current_tab)
      end
    end
    
    # POST /org_admin/templates/:id/copy  (AJAX)
    # -----------------------------------------------------
    def copy
      template = Template.find(params[:id])
      authorize template
      begin
        new_copy = template.generate_copy!(current_user.org)
        flash[:notice] = "#{template_type(template).capitalize} was successfully copied."
        redirect_to edit_org_admin_template_path(new_copy, edit: true, r: 'organisation-templates')
      rescue StandardError => e
        flash[:alert] = failed_create_error(template, template_type(template))
        current_tab = params[:r] || 'all-templates'
        redirect_to "#{org_admin_templates_path}##{current_tab}"
      end
    end
    
    # PATCH /org_admin/templates/:id/publish  (AJAX)
    # -----------------------------------------------------
    def publish
      template = Template.find(params[:id])
      authorize template
      
      # Only allow the current version to be updated
      if template.latest?
        # Unpublish the older published version if there is one
        live = Template.live(template.family_id)
        if !live.nil? and self != live
          live.published = false
          live.save!
        end
        template.published = true
        template.save

        flash[:notice] = _("Your #{template_type(template)} has been published and is now available to users.")
        redirect_to "#{org_admin_templates_path}#{template_type(template) == _('customisation') ? '#funder-templates' : '#organisation-templates'}"
      else
        redirect_to org_admin_templates_path, alert: _("You can not publish a historical version of this #{template_type(template)}.")
      end
    end

    # PATCH /org_admin/templates/:id/unpublish  (AJAX)
    # -----------------------------------------------------
    def unpublish
      template = Template.find(params[:id])
      authorize template

      if template.present?
        template.published = false
        template.save
        flash[:notice] = _("Your #{template_type(template)} is no longer published. Users will not be able to create new DMPs for this #{template_type(template)} until you re-publish it")
      else
        flash[:alert] = _("That #{template_type(template)} is not currently published.")
      end

      redirect_to "#{org_admin_templates_path}#{template_type(template) == _('customisation') ? '#funder-templates' : '#organisation-templates'}"
    end
    
    # GET /org_admin/template_options  (AJAX)
    # Collect all of the templates available for the org+funder combination
    # --------------------------------------------------------------------------
    def template_options()
      org_id = (plan_params[:org_id] == '-1' ? '' : plan_params[:org_id])
      funder_id = (plan_params[:funder_id] == '-1' ? '' : plan_params[:funder_id])
      authorize Template.new
      templates = []

      if org_id.present? || funder_id.present?
        unless funder_id.blank?
          # Load the funder's template(s)
          templates = Template.where(org_id: funder_id).published.publicly_visible
          unless org_id.blank?
            # Swap out any organisational cusotmizations of a funder template
            templates = templates.map do |tmplt|
              customization = Template.published.latest_customized_version(tmplt.family_id, org_id).first
              if customization.present? && tmplt.created_at < customization.created_at
                customization
              else
                tmplt
              end
            end
          end
        end
        
        # If the no funder was specified OR the funder matches the org
        if funder_id.blank? || funder_id == org_id
          # Retrieve the Org's templates
          templates << Template.published.organisationally_visible.where(org_id: org_id, customization_of: nil).to_a
        end
        templates = templates.flatten.uniq
      end

      # If no templates were available use the default template
      if templates.empty?
        templates << Template.where(is_default: true, published: true).first
      end
      templates = (templates.count > 0 ? templates.sort{|x,y| x.title <=> y.title} : [])
      render json: {"templates": templates.collect{|t| {id: t.id, title: t.title} }}.to_json
    end

    
    # ======================================================
    private
    def plan_params
      params.require(:plan).permit(:org_id, :funder_id)
    end
    
    def template_params
      params.require(:template).permit(:title, :description, :visibility, :links)
    end
    
    def template_type(template)
      template.customization_of.present? ? _('customisation') : _('template')
    end
    
  end
end