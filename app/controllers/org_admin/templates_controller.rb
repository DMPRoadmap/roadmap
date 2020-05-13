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
      @templates         = templates.includes(:org).page(1)
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

      @orgs  = current_user.can_change_org? ? Org.all : nil
      @title = if current_user.can_super_admin?
                 _("%{org_name} Templates") % { org_name: current_user.org.name }
               else
                 _("Own Templates")
               end
      @templates         = templates.page(1)
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
      @template = current_org.templates.new
    end

    # POST /org_admin/templates
    def create
      authorize Template
      args = template_params
      # Swap in the appropriate visibility enum value for the checkbox value
      args[:visibility] = args.fetch(:visibility, "0") == "1" ? "organisationally_visible" : "publicly_visible"

      # creates a new template with version 0 and new family_id
      @template = Template.new(args)
      @template.org_id = current_user.org.id
      @template.locale = current_org.language.abbreviation
      @template.links = if params["template-links"].present?
                          ActiveSupport::JSON.decode(params["template-links"])
                        else
                          { "funder": [], "sample_plan": [] }
                        end
      if @template.save
        redirect_to edit_org_admin_template_path(@template),
                    notice: success_message(@template, _("created"))
      else
        flash[:alert] = flash[:alert] = failure_message(@template, _("create"))
        render :new
      end
    end

    # PUT /org_admin/templates/:id (AJAXable)
    # -----------------------------------------------------
    def update
      template = Template.find(params[:id])
      authorize template
      begin
        args = template_params
        # Swap in the appropriate visibility enum value for the checkbox value
        args[:visibility] = args.fetch(:visibility, '0') == '1' ? 'organisationally_visible' : 'publicly_visible'

        template.assign_attributes(args)
        if params["template-links"].present?
          template.links = ActiveSupport::JSON.decode(params["template-links"])
        end
        if template.save
          render(json: {
            status: 200,
            msg: success_message(template, _("saved"))
          })
        else
          render(json: {
            status: :bad_request,
            msg: failure_message(template, _("save"))
          })
        end
      rescue ActiveSupport::JSON.parse_error
        render(json: {
          status: :bad_request,
          msg: _("Error parsing links for a %{template}") %
               { template: template_type(template) }
        })
        return
      rescue => e
        render(json: {
          status: :forbidden,
          msg: e.message
        }) and return
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
            flash[:notice] = success_message(template, _("removed"))
          else
            flash[:alert] = failure_message(template, _("remove"))
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
      publishable, errors = template.publishability
      if publishable
        if template.publish!
          flash[:notice] = _("Your #{template_type(template)} has been published and is now available to users.")
        else
          flash[:alert] = _("Unable to publish your #{template_type(template)}.")
        end
      else
        flash[:alert] = errors
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

    # GET template_export/:id
    # -----------------------------------------------------
    def template_export
      @template = Template.find(params[:id])

      authorize @template
      # now with prefetching (if guidance is added, prefetch annottaions/guidance)
      @template = Template.includes(
        :org,
        phases: {
          sections: {
            questions: [
              :question_options,
              :question_format,
              :annotations
            ]
          }
        }
      ).find(@template.id)

      @formatting = Settings::Template::DEFAULT_SETTINGS[:formatting]

      begin
        file_name = @template.title.gsub(/[^a-zA-Z\d\s]/, "").gsub(/ /, "_") + '_v' + @template.version.to_s
        respond_to do |format|
          format.docx do
            render docx: "template_exports/template_export", filename: "#{file_name}.docx"
          end

          format.pdf do
            # rubocop:disable Metrics/LineLength
            render pdf: file_name,
              template: "template_exports/template_export",
              margin: @formatting[:margin],
              footer: {
                center:    _("Template created using the %{application_name} service. Last modified %{date}") % {
                application_name: Rails.configuration.branding[:application][:name],
                date: l(@template.updated_at.to_date, formats: :short)
              },
              font_size: 8,
              spacing: (@formatting[:margin][:bottom] / 2) - 4,
              right: "[page] of [topage]",
              encoding: "utf8"
            }
            # rubocop:enable Metrics/LineLength
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        # What scenario is this triggered in? it's common to our export pages
        redirect_to public_templates_path,
                    alert: _("Unable to download the DMP Template at this time.")
      end
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
