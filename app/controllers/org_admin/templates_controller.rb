module OrgAdmin
  class TemplatesController < ApplicationController
    include Paginable
    include Versionable
    after_action :verify_authorized

    # The root version of index which returns all templates
    # GET /org_admin/templates
    # -----------------------------------------------------
    def index
      authorize Template
      templates = Template.latest_version
      published = templates.select{|t| t.published? || t.draft? }.length
      render 'index', locals: { 
        orgs: Org.all,
        title: _('All Templates'),
        templates: templates.includes(:org),
        action: 'index',
        query_params: { sort_field: :title, sort_direction: :asc },
        all_count: templates.length,
        published_count: published.present? ? published : 0,
        unpublished_count: published.present? ? (templates.length - published): templates.length
      }
    end
    
    # A version of index that displays only templates that belong to the user's org
    # GET /org_admin/templates/organisational
    # -----------------------------------------------------
    def organisational
      authorize Template
      templates = Template.latest_version_per_org(current_user.org.id).where(customization_of: nil, org_id: current_user.org.id)
      published = templates.select{|t| t.published? || t.draft? }.length
      title = current_user.can_super_admin? ? _('%{org_name} Templates') % { org_name: current_user.org.name } : _('Own Templates')
      render 'index', locals: { 
        orgs: current_user.can_super_admin? ? Org.all : nil,
        title: title,
        templates: templates,
        action: 'organisational',
        query_params: { sort_field: :title, sort_direction: :asc },
        all_count: templates.length,
        published_count: published.present? ? published : 0,
        unpublished_count: published.present? ? (templates.length - published): templates.length
      }
    end

    # A version of index that displays only templates that are customizable
    # GET /org_admin/templates/customisable
    # -----------------------------------------------------
    def customisable
      authorize Template
      customizations = Template.latest_customized_version_per_org(current_user.org.id).where(org_id: current_user.org.id)
      funder_templates = Template.latest_customizable.includes(:org)
      # We use this to validate the counts below in the event that a template was customized but the base template
      # org is no longer a funder
      funder_template_families = funder_templates.collect(&:family_id)
      published = customizations.select{|t| t.published? || t.draft? }.length
      render 'index', locals: { 
        orgs: (current_user.can_super_admin? ? Org.all : []),
        title: _('Customizable Templates'),
        templates: funder_templates,
        customizations: customizations,
        action: 'customisable',
        query_params: { sort_field: :title, sort_direction: :asc },
        all_count: funder_templates.length,
        published_count: published.present? ? published : 0,
        unpublished_count: published.present? ? (customizations.length - published): customizations.length,
        not_customized_count: funder_templates.length - customizations.length
      }
    end
    
    # GET /org_admin/templates/[:id]
    def show
      template = Template.find(params[:id])
      authorize template
      # Load the info needed for the overview section if the authorization check passes!
      phases = template.phases.includes(sections: { questions: :question_options }).
                        order('phases.number', 'sections.number', 'questions.number', 'question_options.number').
                        select('phases.title', 'phases.description', 'sections.title', 'questions.text', 'question_options.text')
      if !template.latest?
        flash[:notice] = _('You are viewing a historical version of this template. You will not be able to make changes.')
      end
      render 'container', locals: { 
        partial_path: 'show', 
        template: template,
        phases: phases,
        referrer: get_referrer(template, request.referrer) }
    end
    
    # GET /org_admin/templates/:id/edit
    # -----------------------------------------------------
    def edit
      template = Template.includes(:org, :phases).find(params[:id])
      authorize template
      # Load the info needed for the overview section if the authorization check passes!
      phases = template.phases.includes(sections: { questions: :question_options }).
                        order('phases.number', 'sections.number', 'questions.number', 'question_options.number').
                        select('phases.title', 'phases.description', 'sections.title', 'questions.text', 'question_options.text')
      if !template.latest?
        flash[:notice] = _("You are viewing a historical version of this #{template_type(template)}. You will not be able to make changes.")
      end
      render 'container', locals: { 
        partial_path: 'edit', 
        template: template,
        phases: phases,
        referrer: get_referrer(template, request.referrer) }
    end
    
    # GET /org_admin/templates/new
    # -----------------------------------------------------
    def new
      authorize Template
      render 'container', locals: { 
        partial_path: 'new', 
        template: Template.new(org: current_user.org),
        referrer: request.referrer.present? ? request.referrer : org_admin_templates_path }
    end
    
    # POST /org_admin/templates
    # -----------------------------------------------------
    def create
      authorize Template
      # creates a new template with version 0 and new family_id
      template = Template.new(template_params)
      template.org_id = current_user.org.id
      template.links = (params["template-links"].present? ? ActiveSupport::JSON.decode(params["template-links"]) : {"funder": [], "sample_plan": []})
      if template.save!
        redirect_to edit_org_admin_template_path(template), notice: success_message(template_type(template), _('created'))
      else
        flash[:alert] = failed_create_error(template, template_type(template))
        render partial: "org_admin/templates/new", locals: { template: template, hash: hash }
      end
    end
    
    # PUT /org_admin/templates/:id (AJAXable)
    # -----------------------------------------------------
    def update
      template = Template.find(params[:id])
      authorize template 
      begin
        template.assign_attributes(template_params)
        template.links = ActiveSupport::JSON.decode(params["template-links"]) if params["template-links"].present?
        if template.save!
          render(status: :ok, json: { msg: success_message(template_type(template), _('saved'))})
        else
          # Note failed_update_error may return HTML tags (e.g. <br/>) and therefore the client should parse them accordingly
          render(status: :bad_request, json: { msg: failed_update_error(template, template_type(template))})
        end
      rescue ActiveSupport::JSON.parse_error
        render(status: :bad_request, json: { msg: _("Error parsing links for a #{template_type(template)}") }) and return
      rescue => e
        render(status: :forbidden, json: { msg: e.message }) and return
      end
    end
    
    # DELETE /org_admin/templates/:id
    # -----------------------------------------------------
    def destroy
      template = Template.find(params[:id])
      authorize template
      versions = Template.includes(:plans).where(family_id: template.family_id)
      if versions.select{|t| t.plans.length > 0 }.empty?
        versions.each do |version|
          if version.destroy!
            flash[:notice] = success_message(template_type(template), _('removed'))
          else
            flash[:alert] = failed_destroy_error(template, template_type(template))
          end
        end
      else
        flash[:alert] = _("You cannot delete a #{template_type(template)} that has been used to create plans.")
      end
      redirect_to request.referrer.present? ? request.referrer : org_admin_templates_path
    end

    # GET /org_admin/templates/:id/history
    # -----------------------------------------------------
    def history
      template = Template.find(params[:id])
      authorize template
      templates = Template.where(family_id: template.family_id)
      render 'history', locals: { 
        templates: templates, 
        referrer: template.customization_of.present? ? customisable_org_admin_templates_path : organisational_org_admin_templates_path,
        current: templates.maximum(:version)
      }
    end
    
    # POST /org_admin/templates/:id/customize
    # -----------------------------------------------------
    def customize
      template = Template.find(params[:id])
      authorize template
      if template.customize?(current_user.org)
        begin
          customisation = template.customize!(current_user.org)
          redirect_to org_admin_template_path(customisation)
        rescue StandardError => e
          flash[:alert] = _('Unable to customize that template.')
          redirect_to request.referrer.present? ? request.referrer : org_admin_templates_path
        end
      else
        flash[:notice] = _('That template is not customizable.')
        redirect_to request.referrer.present? ? request.referrer : org_admin_templates_path
      end
    end

    # POST /org_admin/templates/:id/transfer_customization
    # the funder template's id is passed through here
    # -----------------------------------------------------
    def transfer_customization
      template = Template.includes(:org).find(params[:id])
      authorize template
      if template.upgrade_customization?
        begin
          new_customization = template.upgrade_customization!
          redirect_to org_admin_template_path(new_customization)
        rescue StandardError => e
          flash[:alert] = _('Unable to transfer your customizations.')
          redirect_to request.referrer.present? ? request.referrer : org_admin_templates_path
        end
      else
        flash[:notice] = _('That template is no longer customizable.')
        redirect_to request.referrer.present? ? request.referrer : org_admin_templates_path
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
        redirect_to edit_org_admin_template_path(new_copy)
      rescue StandardError => e
        flash[:alert] = failed_create_error(template, template_type(template))
        redirect_to request.referrer.present? ? request.referrer : org_admin_templates_path
      end
    end
    
    # PATCH /org_admin/templates/:id/publish  (AJAX)
    # -----------------------------------------------------
    def publish
      template = Template.find(params[:id])
      authorize template
      if template.latest?
        # Now make the current version published
        if template.update_attributes!({ published: true })
          flash[:notice] = _("Your #{template_type(template)} has been published and is now available to users.")
        else
          flash[:alert] = _("Unable to publish your #{template_type(template)}.")
        end
      else
        flash[:alert] = _("You can not publish a historical version of this #{template_type(template)}.")
      end
      redirect_to request.referrer.present? ? request.referrer : org_admin_templates_path
    end

    # PATCH /org_admin/templates/:id/unpublish  (AJAX)
    # -----------------------------------------------------
    def unpublish
      template = Template.find(params[:id])
      authorize template
      versions = Template.where(family_id: template.family_id)
      versions.each do |version|
        unless version.update_attributes!({ published: false })
          flash[:alert] = _("Unable to unpublish your #{template_type(template)}.")
        end
      end
      flash[:notice] = _("Successfully unpublished your #{template_type(template)}") unless flash[:alert].present?
      redirect_to request.referrer.present? ? request.referrer : org_admin_templates_path
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
          # Load the funder's template(s) minus the default template (that gets swapped in below if NO other templates are available)
          templates = Template.latest_customizable.where(org_id: funder_id).select{ |t| !t.is_default? }
          unless org_id.blank?
            # Swap out any organisational cusotmizations of a funder template
            templates = templates.map do |tmplt|
              customization = Template.published.latest_customized_version(tmplt.family_id, org_id).first
              # Only provide the customized version if its still up to date with the funder template!
              if customization.present? && !customization.upgrade_customization?
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
        default = Template.default
        if default.present?
          customization = Template.published.latest_customized_version(default.family_id, org_id).first
          templates << (customization.present? ? customization : default)
        end
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
   
    def get_referrer(template, referrer)
      if referrer.present?  
puts "REFERRER: #{referrer}"
        if referrer.end_with?(new_org_admin_template_path) || referrer.end_with?(edit_org_admin_template_path) || referrer.end_with?(org_admin_template_path) 
          template.customization_of.present? ? customisable_org_admin_templates_path : organisational_org_admin_templates_path 
        else 
          request.referrer
        end
      else
        org_admin_templates_path
      end
    end
  end
end