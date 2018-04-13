module OrgAdmin
  class TemplatesController < ApplicationController
    include Paginable
    include TemplateFilter
    after_action :verify_authorized

    # GET /org_admin/templates
    # -----------------------------------------------------
    def index
      authorize Template
      
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
    
    # GET /org_admin/templates/new
    # -----------------------------------------------------
    def new
      authorize Template
      @current_tab = params[:r] || 'all-templates'
    end
    
    # POST /org_admin/templates
    # -----------------------------------------------------
    def create
      authorize Template
      # creates a new template with version 0 and new family_id
      @template = Template.new(params[:template])
      @template.org_id = current_user.org.id
      @template.description = params['template-desc']
      @template.links = (params["template-links"].present? ? JSON.parse(params["template-links"]) : {"funder": [], "sample_plan": []})

      if @template.save
        redirect_to edit_org_admin_template_path(@template), notice: success_message(template_type(@template), _('created'))
      else
        @hash = @template.to_hash
        flash[:alert] = failed_create_error(@template, template_type(@template))
        render action: "new"
      end
    end
    
    # GET /org_admin/templates/:id/edit
    # -----------------------------------------------------
    def edit
      @template = Template.includes(:org, phases: [sections: [questions: [:question_options, :question_format, :annotations]]]).find(params[:id])
      authorize @template

      @current = Template.current(@template.family_id)
      @current_tab = params[:r] || 'all-templates'
      
      if @template == @current 
        if @template.published?
          new_version = @template.generate_version!
          if !new_version.nil?
            redirect_to(action: 'edit', id: new_version.id, r: @current_tab)
            return
          else
            flash[:alert] = _("Unable to create a new version of this #{template_type(@template)}. You are currently working with a published copy.")
          end
        end
      else
        flash[:notice] = _("You are viewing a historical version of this #{template_type(@template)}. You will not be able to make changes.")
      end

      # once the correct template has been generated, we convert it to hash
      @template_hash = @template.to_hash
      
      render('container',
        locals: { 
          partial_path: 'edit',
          template: @template,
          current: @current,
          edit: @template == @current,
          template_hash: @template_hash,
          current_tab: @current_tab
        })
    end
    
    # PUT /org_admin/templates/:id (AJAXable)
    # -----------------------------------------------------
    def update
      @template = Template.find(params[:id])
      authorize @template   # NOTE if non-authorized error is raised, it performs a redirect to root_path and no JSON output is generated

      current = Template.current(@template.family_id)

      # Only allow the current version to be updated
      if current != @template
        render(status: :forbidden, json: { msg: _("You can not edit a historical version of this #{template_type(@template)}.")})
      else
        template_links = nil
        begin
          template_links = JSON.parse(params["template-links"]) if params["template-links"].present?
        rescue JSON::ParserError
          render(status: :bad_request, json: { msg: _("Error parsing links for a #{template_type(@template)}") })
          return
        end
        
        @template.description = params["template-desc"]
        @template.links = template_links if template_links.present?
      
        # If the visibility checkbox is not checked and the user's org is a funder set the visibility to public
        # otherwise default it to organisationally_visible
        if current_user.org.funder? && params[:template_visibility].nil?
          @template.visibility = Template.visibilities[:publicly_visible]
        else
          @template.visibility = Template.visibilities[:organisationally_visible]
        end
      
        if @template.update_attributes(params[:template])
          render(status: :ok, json: { msg: success_message(template_type(@template), _('saved'))})
        else
          # Note failed_update_error may return HTML tags (e.g. <br/>) and therefore the client should parse them accordingly
          render(status: :bad_request, json: { msg: failed_update_error(@template, template_type(@template))})
        end
      end
    end
    
    # DELETE /org_admin/templates/:id
    # -----------------------------------------------------
    def destroy
      @template = Template.find(params[:id])
      current_tab = params[:r] || 'all-templates'
      authorize @template

      if @template.plans.length <= 0
        current = Template.current(@template.family_id)

        # Only allow the current version to be destroyed
        if current == @template
          if @template.destroy
            flash[:notice] = success_message(template_type(@template), _('removed'))
            redirect_to org_admin_templates_path(r: current_tab)
          else
            @hash = @template.to_hash
            flash[:alert] = failed_destroy_error(@template, template_type(@template))
            redirect_to org_admin_templates_path(r: current_tab)
          end
        else
          flash[:alert] = _("You cannot delete historical versions of this #{template_type(@template)}.")
          redirect_to org_admin_templates_path(r: current_tab)
        end
      else
        flash[:alert] = _("You cannot delete a #{template_type(@template)} that has been used to create plans.")
        redirect_to org_admin_templates_path(r: current_tab)
      end
    end

    # GET /org_admin/templates/:id/history
    # -----------------------------------------------------
    def history
      @template = Template.find(params[:id])
      authorize @template
      @templates = Template.where(family_id: @template.family_id)
      @current = Template.current(@template.family_id)
      @current_tab = params[:r] || 'all-templates'
    end
    
    # GET /org_admin/templates/:id/customize
    # -----------------------------------------------------
    def customize
      @template = Template.find(params[:id])
      authorize @template
      # TODO use POST instead of GET since we are effectively adding a new template resource
      # TODO add check @template.customize? before
      customisation = @template.customize!(current_user.org)
      
      @current_tab = params[:r] || 'all-templates'
      redirect_to edit_org_admin_template_path(customisation, r: 'funder-templates')
    end

    # GET /org_admin/templates/:id/transfer_customization
    # the funder template's id is passed through here
    # -----------------------------------------------------
    def transfer_customization
      @template = Template.includes(:org).find(params[:id])
      @current_tab = params[:r] || 'all-templates'
      authorize @template
      # TODO add check @template.upgrade_customization?
      new_customization = @template.upgrade_customization!
      new_customization.save!
      redirect_to edit_org_admin_template_path(new_customization, r: 'funder-templates')
    end
    
    # PUT /org_admin/templates/:id/copy  (AJAX)
    # -----------------------------------------------------
    def copy
      template = Template.find(params[:id])
      authorize template
      begin
        new_copy = template.generate_copy!(current_user.org)
        flash[:notice] = "#{template_type(template).capitalize} was successfully copied."
        redirect_to edit_org_admin_template_path(new_copy, edit: true, r: 'organisation-templates')
      rescue ActiveRecord::RecordInvalid => e
        flash[:alert] = failed_create_error(template, template_type(template))
        current_tab = params[:r] || 'all-templates'
        redirect_to "#{org_admin_templates_path}##{current_tab}"
      end
    end
    
    # GET /org_admin/templates/:id/publish  (AJAX)  TODO convert to PUT verb
    # -----------------------------------------------------
    def publish
      template = Template.find(params[:id])
      authorize template
      current = Template.current(template.family_id)
      
      # Only allow the current version to be updated
      if current != template
        redirect_to org_admin_templates_path, alert: _("You can not publish a historical version of this #{template_type(template)}.")
      else
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
      end
    end

    # GET /org_admin/templates/:id/unpublish  (AJAX)  TODO convert to PUT verb
    # -----------------------------------------------------
    def unpublish
      template = Template.find(params[:id])
      authorize template

      if template.nil?
        flash[:alert] = _("That #{template_type(template)} is not currently published.")
      else
        template.published = false
        template.save
        flash[:notice] = _("Your #{template_type(template)} is no longer published. Users will not be able to create new DMPs for this #{template_type(template)} until you re-publish it")
      end

      redirect_to "#{org_admin_templates_path}#{template_type(template) == _('customisation') ? '#funder-templates' : '#organisation-templates'}"
    end
    
    # PUT /org_admin/template_options  (AJAX)
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
          templates = Template.publicly_visible.where(published: true, org_id: funder_id).to_a

          unless org_id.blank?
            # Swap out any organisational cusotmizations of a funder template
            templates.each do |tmplt|
              customization = Template.unarchived.find_by(published: true, org_id: org_id, customization_of: tmplt.family_id)
              if customization.present? && tmplt.created_at < customization.created_at
                templates.delete(tmplt)
                templates << customization
              end
            end
          end
        end
        
        # If the no funder was specified OR the funder matches the org
        if funder_id.blank? || funder_id == org_id
          # Retrieve the Org's templates
          templates << Template.organisationally_visible.unarchived.where(published: true, org_id: org_id, customization_of: nil).to_a
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
    
    def template_type(template)
      template.customization_of.present? ? _('customisation') : _('template')
    end
    
  end
end