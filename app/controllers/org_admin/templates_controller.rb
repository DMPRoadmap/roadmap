# frozen_string_literal: true

module OrgAdmin

  class TemplatesController < ApplicationController

    include Paginable
    include Versionable
    include TemplateMethods

    after_action :verify_authorized

    # The root version of index which returns all templates
    # GET /org_admin/templates
    # -----------------------------------------------------
    def index
      authorize Template
      templates = Template.latest_version.where(customization_of: nil)
      published = templates.select { |t| t.published? || t.draft? }.length

      @orgs              = Org.all
      @title             = _("All Templates")
      @templates         = templates.includes(:org)
      @query_params      = { sort_field: "templates.title", sort_direction: "asc" }
      @all_count         = templates.length
      @published_count   = published.present? ? published : 0
      @unpublished_count = if published.present?
                             (templates.length - published)
                           else
                             templates.length
                           end
      render :index
    end

    # A version of index that displays only templates that belong to the user's org
    # GET /org_admin/templates/organisational
    # -----------------------------------------------------
    def organisational
      authorize Template
      templates = Template.latest_version_per_org(current_user.org.id)
                          .where(customization_of: nil, org_id: current_user.org.id)
      published = templates.select { |t| t.published? || t.draft? }.length

      @orgs  = current_user.can_super_admin? ? Org.all : nil
      @title = if current_user.can_super_admin?
                 _("%{org_name} Templates") % { org_name: current_user.org.name }
               else
                 _("Own Templates")
               end
      @templates         = templates
      @query_params      = { sort_field: "templates.title", sort_direction: "asc" }
      @all_count         = templates.length
      @published_count   = published.present? ? published : 0
      @unpublished_count = if published.present?
                             templates.length - published
                           else
                             templates.length
                           end
      render :index
    end

    # A version of index that displays only templates that are customizable
    # GET /org_admin/templates/customisable
    # -----------------------------------------------------
    def customisable
      authorize Template
      customizations = Template.latest_customized_version_per_org(current_user.org.id)
                               .where(org_id: current_user.org.id)
      funder_templates = Template.latest_customizable.includes(:org)
      # We use this to validate the counts below in the event that a template was
      # customized but the base template org is no longer a funder
      funder_template_families = funder_templates.collect(&:family_id)
      # filter only customizations of valid(published) funder templates
      customizations = customizations.select { |t|
                  funder_template_families.include?(t.customization_of) }
      published = customizations.select { |t| t.published? || t.draft? }.length

      @orgs = current_user.can_super_admin? ? Org.all : []
      @title = _("Customizable Templates")
      @templates = funder_templates
      @customizations = customizations
      @query_params = { sort_field: "templates.title", sort_direction: "asc" }
      @all_count = funder_templates.length
      @published_count = published.present? ? published : 0
      @unpublished_count = if published.present?
                             (customizations.length - published)
                           else
                             customizations.length
                           end
      @not_customized_count = funder_templates.length - customizations.length

      render :index
    end

    # GET /org_admin/templates/[:id]
    def show
      template = Template.find(params[:id])
      authorize template
      # Load the info needed for the overview section if the authorization check passes!
      phases = template.phases
                       .includes(sections: { questions: :question_options })
                       .order("phases.number", "sections.number", "questions.number",
                              "question_options.number")
                       .select("phases.title", "phases.description", "sections.title",
                               "questions.text", "question_options.text")
      if !template.latest?
        # rubocop:disable Metrics/LineLength
        flash[:notice] = _("You are viewing a historical version of this template. You will not be able to make changes.")
        # rubocop:enable Metrics/LineLength
      end
      render "container", locals: {
        partial_path: "show",
        template: template,
        phases: phases,
        referrer: get_referrer(template, request.referrer) }
    end

    # GET /org_admin/templates/:id/edit
    def edit
      template = Template.includes(:org, :phases).find(params[:id])
      authorize template
      # Load the info needed for the overview section if the authorization check passes!
      phases = template.phases.includes(sections: { questions: :question_options }).
                        order("phases.number",
                              "sections.number",
                              "questions.number",
                              "question_options.number").
                        select("phases.title",
                               "phases.description",
                               "sections.title",
                               "questions.text",
                               "question_options.text")
      if !template.latest?
        redirect_to org_admin_template_path(id: template.id)
      else
        render "container", locals: {
          partial_path: "edit",
          template: template,
          phases: phases,
          referrer: get_referrer(template, request.referrer) }
      end
    end

    # GET /org_admin/templates/new
    def new
      authorize Template
      render "container", locals: {
        partial_path: "new",
        template: Template.new(org: current_user.org),
        referrer: request.referrer.present? ? request.referrer : org_admin_templates_path
      }
    end

    # POST /org_admin/templates
    def create
      authorize Template
      # creates a new template with version 0 and new family_id
      template = Template.new(template_params)
      template.org_id = current_user.org.id
      template.links = if params["template-links"].present?
                         ActiveSupport::JSON.decode(params["template-links"])
                       else
                         { "funder": [], "sample_plan": [] }
                       end
      if template.save
        redirect_to edit_org_admin_template_path(template),
                    notice: success_message(template_type(template), _("created"))
      else
        flash[:alert] = failed_create_error(template, template_type(template))
        render partial: "org_admin/templates/new",
               locals: { template: template, hash: hash }
      end
    end

    # PUT /org_admin/templates/:id (AJAXable)
    # -----------------------------------------------------
    def update
      template = Template.find(params[:id])
      authorize template
      begin
        template.assign_attributes(template_params)
        if params["template-links"].present?
          template.links = ActiveSupport::JSON.decode(params["template-links"])
        end
        if template.save
          render(status: :ok,
                 json: { msg: success_message(template_type(template), _("saved")) })
        else
          # Note failed_update_error may return HTML tags (e.g. <br/>) and therefore the
          # client should parse them accordingly
          render(status: :bad_request,
                 json: { msg: failed_update_error(template, template_type(template)) })
        end
      rescue ActiveSupport::JSON.parse_error
        render(status: :bad_request,
               json: { msg: _("Error parsing links for a #{template_type(template)}") })
        return
      rescue => e
        render(status: :forbidden, json: { msg: e.message }) and return
      end
    end

    # DELETE /org_admin/templates/:id
    def destroy
      template = Template.find(params[:id])
      authorize template
      versions = Template.includes(:plans).where(family_id: template.family_id)
      if versions.select { |t| t.plans.length > 0 }.empty?
        versions.each do |version|
          if version.destroy!
            flash[:notice] = success_message(template_type(template), _("removed"))
          else
            flash[:alert] = failed_destroy_error(template, template_type(template))
          end
        end
      else
        # rubocop:disable Metrics/LineLength
        flash[:alert] = _("You cannot delete a #{template_type(template)} that has been used to create plans.")
        # rubocop:enable Metrics/LineLength
      end
      if request.referrer.present?
        redirect_to request.referrer
      else
        redirect_to org_admin_templates_path
      end
    end

    # GET /org_admin/templates/:id/history
    def history
      template = Template.find(params[:id])
      authorize template
      templates = Template.where(family_id: template.family_id)
      local_referrer = if template.customization_of.present?
                         customisable_org_admin_templates_path
                       else
                         organisational_org_admin_templates_path
                       end
      render "history", locals: {
        templates: templates,
        query_params: { sort_field: "templates.version", sort_direction: "desc" },
        referrer: local_referrer,
        current: templates.maximum(:version)
      }
    end

    # PATCH /org_admin/templates/:id/publish  (AJAX)
    def publish
      template = Template.find(params[:id])
      authorize template
      # rubocop:disable Metrics/LineLength
      if template.latest?
        # Now make the current version published
        if template.update_attributes!(published: true)
          flash[:notice] = _("Your #{template_type(template)} has been published and is now available to users.")
        else
          flash[:alert] = _("Unable to publish your #{template_type(template)}.")
        end
      else
        flash[:alert] = _("You can not publish a historical version of this #{template_type(template)}.")
      end
      # rubocop:enable Metrics/LineLength
      redirect_to request.referrer.present? ? request.referrer : org_admin_templates_path
    end

    # PATCH /org_admin/templates/:id/unpublish  (AJAX)
    def unpublish
      template = Template.find(params[:id])
      authorize template
      versions = Template.where(family_id: template.family_id)
      versions.each do |version|
        unless version.update_attributes!(published: false)
          flash[:alert] = _("Unable to unpublish your #{template_type(template)}.")
        end
      end
      unless flash[:alert].present?
        flash[:notice] = _("Successfully unpublished your #{template_type(template)}")
      end
      redirect_to request.referrer.present? ? request.referrer : org_admin_templates_path
    end

    private

    def template_params
      params.require(:template).permit(:title, :description, :visibility, :links)
    end

    def get_referrer(template, referrer)
      return org_admin_templates_path unless referrer.present?
      if referrer.end_with?(new_org_admin_template_path) ||
           referrer.end_with?(edit_org_admin_template_path) ||
           referrer.end_with?(org_admin_template_path)

        if template.customization_of.present?
          customisable_org_admin_templates_path
        else
          organisational_org_admin_templates_path
        end
      else
        request.referrer
      end
    end

  end

end
