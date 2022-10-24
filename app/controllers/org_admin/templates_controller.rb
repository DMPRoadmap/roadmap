# frozen_string_literal: true

module OrgAdmin
  # Controller that handles templates
  class TemplatesController < ApplicationController
    include Paginable
    include Versionable
    include TemplateMethods

    after_action :verify_authorized

    # The root version of index which returns all templates
    # GET /org_admin/templates
    # rubocop:disable Metrics/AbcSize
    def index
      authorize Template
      templates = Template.latest_version.where(customization_of: nil)
      published = templates.select { |t| t.published? || t.draft? }.length

      @orgs              = Org.includes(:identifiers).managed
      @title             = _('All Templates')
      @templates         = templates.includes(:org).page(1)
      @query_params      = { sort_field: 'templates.title', sort_direction: 'asc' }
      @all_count         = templates.length
      @published_count   = published.present? ? published : 0
      @unpublished_count = if published.present?
                             (templates.length - published)
                           else
                             templates.length
                           end
      render :index
    end
    # rubocop:enable Metrics/AbcSize

    # A version of index that displays only templates that belong to the user's org
    # GET /org_admin/templates/organisational
    # -----------------------------------------------------
    # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
    def organisational
      authorize Template
      templates = Template.latest_version_per_org(current_user.org.id)
                          .where(customization_of: nil, org_id: current_user.org.id)
      published = templates.select { |t| t.published? || t.draft? }.length

      @orgs  = current_user.can_super_admin? ? Org.includes(:identifiers).all : nil
      @title = if current_user.can_super_admin?
                 format(_('%{org_name} Templates'), org_name: current_user.org.name)
               else
                 _('Own Templates')
               end
      @templates = templates.page(1)
      @query_params = { sort_field: 'templates.title', sort_direction: 'asc' }
      @all_count = templates.length
      @published_count = published.present? ? published : 0
      @unpublished_count = if published.present?
                             templates.length - published
                           else
                             templates.length
                           end
      render :index
    end
    # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity

    # A version of index that displays only templates that are customizable
    # GET /org_admin/templates/customisable
    # -----------------------------------------------------
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def customisable
      authorize Template
      customizations = Template.latest_customized_version_per_org(current_user.org.id)
                               .where(org_id: current_user.org.id)
      funder_templates = Template.latest_customizable.includes(:org)
      # We use this to validate the counts below in the event that a template was
      # customized but the base template org is no longer a funder
      funder_template_families = funder_templates.collect(&:family_id)
      # filter only customizations of valid(published) funder templates
      customizations = customizations.select do |t|
        funder_template_families.include?(t.customization_of)
      end
      published = customizations.select { |t| t.published? || t.draft? }.length

      @orgs = current_user.can_super_admin? ? Org.includes(:identifiers).all : []
      @title = _('Customizable Templates')
      @templates = funder_templates
      @customizations = customizations
      @query_params = { sort_field: 'templates.title', sort_direction: 'asc' }
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
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # GET /org_admin/templates/[:id]
    def show
      template = Template.find(params[:id])
      authorize template
      # Load the info needed for the overview section if the authorization check passes!
      phases = template.phases
                       .includes(sections: { questions: :question_options })
                       .order('phases.number', 'sections.number', 'questions.number',
                              'question_options.number')
                       .select('phases.title', 'phases.description', 'phases.modifiable',
                               'sections.title', 'questions.text', 'question_options.text')
      unless template.latest?
        # rubocop:disable Layout/LineLength
        flash[:notice] = _('You are viewing a historical version of this template. You will not be able to make changes.')
        # rubocop:enable Layout/LineLength
      end
      render 'container', locals: {
        partial_path: 'show',
        template: template,
        phases: phases,
        referrer: get_referrer(template, request.referrer)
      }
    end

    # GET /org_admin/templates/:id/edit
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def edit
      template = Template.includes(:org, :phases).find(params[:id])
      authorize template
      # Load the info needed for the overview section if the authorization check passes!
      phases = template.phases.includes(sections: { questions: :question_options })
                       .order('phases.number',
                              'sections.number',
                              'questions.number',
                              'question_options.number')
                       .select('phases.title',
                               'phases.description',
                               'phases.modifiable',
                               'sections.title',
                               'questions.text',
                               'question_options.text')
      if template.latest?
        render 'container', locals: {
          partial_path: 'edit',
          template: template,
          phases: phases,
          referrer: get_referrer(template, request.referrer)
        }
      else
        redirect_to org_admin_template_path(id: template.id)
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # GET /org_admin/templates/new
    def new
      authorize Template
      @template = current_org.templates.new
    end

    # POST /org_admin/templates
    # rubocop:disable Metrics/AbcSize
    def create
      authorize Template
      args = template_params
      # Swap in the appropriate visibility enum value for the checkbox value
      args[:visibility] = parse_visibility(args, current_user.org)

      # creates a new template with version 0 and new family_id
      @template = Template.new(args)
      @template.org_id = current_user.org.id
      @template.locale = current_org.language.abbreviation
      @template.links = if params['template-links'].present?
                          ActiveSupport::JSON.decode(params['template-links'])
                        else
                          { funder: [], sample_plan: [] }
                        end
      if @template.save
        redirect_to edit_org_admin_template_path(@template),
                    notice: success_message(@template, _('created'))
      else
        flash[:alert] = flash[:alert] = failure_message(@template, _('create'))
        render :new
      end
    end
    # rubocop:enable Metrics/AbcSize

    # PUT /org_admin/templates/:id (AJAXable)
    # -----------------------------------------------------
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def update
      template = Template.find(params[:id])
      authorize template
      begin
        args = template_params
        # Swap in the appropriate visibility enum value for the checkbox value
        args[:visibility] = parse_visibility(args, current_user.org)

        template.assign_attributes(args)
        template.links = ActiveSupport::JSON.decode(params['template-links']) if params['template-links'].present?
        if template.save
          render(json: {
                   status: 200,
                   msg: success_message(template, _('saved'))
                 })
        else
          render(json: {
                   status: :bad_request,
                   msg: failure_message(template, _('save'))
                 })
        end
      rescue ActiveSupport::JSON.parse_error
        render(json: {
                 status: :bad_request,
                 msg: format(_('Error parsing links for a %{template}'),
                             template: template_type(template))
               })
        nil
      rescue StandardError => e
        render(json: {
                 status: :forbidden,
                 msg: e.message
               }) and return
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # DELETE /org_admin/templates/:id
    # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
    def destroy
      template = Template.find(params[:id])
      authorize template
      versions = Template.includes(:plans).where(family_id: template.family_id)
      if versions.reject { |t| t.plans.empty? }.empty?
        versions.each do |version|
          if version.destroy!
            flash[:notice] = success_message(template, _('removed'))
          else
            flash[:alert] = failure_message(template, _('remove'))
          end
        end
      else
        flash[:alert] = _("You cannot delete a #{template_type(template)} that has been used to create plans.")
      end
      if request.referrer.present?
        redirect_to request.referrer
      else
        redirect_to org_admin_templates_path
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity

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
      render 'history', locals: {
        templates: templates,
        query_params: { sort_field: 'templates.version', sort_direction: 'desc' },
        referrer: local_referrer,
        current: templates.maximum(:version)
      }
    end

    # PATCH /org_admin/templates/:id/publish  (AJAX)
    # rubocop:disable Metrics/AbcSize
    def publish
      template = Template.find(params[:id])
      authorize template
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
      redirect_to request.referrer.present? ? request.referrer : org_admin_templates_path
    end
    # rubocop:enable Metrics/AbcSize

    # PATCH /org_admin/templates/:id/unpublish  (AJAX)
    # rubocop:disable Metrics/AbcSize
    def unpublish
      template = Template.find(params[:id])
      authorize template
      Template.transaction do
        # expected: template is latest
        template.generate_version! if template.published? && template.plans.any?
        Template.where(family_id: template.family_id)
                .update_all(published: false)
      end
      flash[:notice] = _("Successfully unpublished your #{template_type(template)}") unless flash[:alert].present?
      redirect_to request.referrer.present? ? request.referrer : org_admin_templates_path
    end
    # rubocop:enable Metrics/AbcSize

    # GET template_export/:id
    # -----------------------------------------------------
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def template_export
      @template = Template.find(params[:id])

      authorize @template
      # now with prefetching (if guidance is added, prefetch annottaions/guidance)
      @template = Template.includes(
        :org,
        phases: {
          sections: {
            questions: %i[
              question_options
              question_format
              annotations
            ]
          }
        }
      ).find(@template.id)

      @formatting = Settings::Template::DEFAULT_SETTINGS[:formatting]

      begin
        safe_title = @template.title.gsub(/[^a-zA-Z\d\s]/, '').gsub(/ /, '_')
        file_name = "#{safe_title}_v#{@template.version}"
        respond_to do |format|
          format.docx do
            render docx: 'template_exports/template_export', filename: "#{file_name}.docx"
          end

          format.pdf do
            # rubocop:disable Layout/LineLength
            render pdf: file_name,
                   template: 'template_exports/template_export',
                   margin: @formatting[:margin],
                   footer: {
                     center: format(_('Template created using the %{application_name} service. Last modified %{date}'), application_name: ApplicationService.application_name, date: l(@template.updated_at.to_date, formats: :short)),
                     font_size: 8,
                     spacing: (@formatting[:margin][:bottom] / 2) - 4,
                     right: '[page] of [topage]',
                     encoding: 'utf8'
                   }
            # rubocop:enable Layout/LineLength
          end
        end
      rescue ActiveRecord::RecordInvalid
        # What scenario is this triggered in? it's common to our export pages
        redirect_to public_templates_path,
                    alert: _('Unable to download the DMP Template at this time.')
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    def template_params
      # TODO: For some reason the sample plans and funder links are sent outside
      #       the context of the form as :template-links like this:
      #         { "template-links"=>"{
      #           \"funder\":[{
      #             \"link\":\"https://sloan.org/grants/apply#tab-grant-proposal-guidelines\",
      #             \"text\":\"Sloan Grant Proposal Guidelines\"
      #           }],
      #           \"sample_plan\":[{
      #             \"link\":\"https://dmptool.org\",
      #             \"text\":\"DMPTool\"
      #           }]
      #         }
      # While this is working as-is we should consider folding these into
      # the template: :links context.
      params.require(:template).permit(:title, :description, :visibility, :links)
    end

    def parse_visibility(args, org)
      # the visibility param is only present in the case of an org that is
      # both a funder and an institution.
      # If nil and the org is a funder, we default to public
      # If nil and the org is not a funder, we default to organisational
      # If present, we parse to retrieve the value
      if args[:visibility].nil?
        org.funder? ? 'publicly_visible' : 'organisationally_visible'
      else
        args.fetch(:visibility, '0') == '1' ? 'organisationally_visible' : 'publicly_visible'
      end
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
