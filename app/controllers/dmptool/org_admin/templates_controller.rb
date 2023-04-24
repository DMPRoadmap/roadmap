# frozen_string_literal: true

module Dmptool
  module OrgAdmin
    # Helper method that loads the selected Template's email subject/body when the
    # modal window opens for the 'Email Template' function
    module TemplatesController
      # GET /org_admin/templates/132/email (AJAX)
      #------------------------------------------
      # rubocop:disable Metrics/AbcSize
      def email
        @template = Template.find_by(id: params[:id])
        authorize @template

        subject = format(_('A new data management plan (DMP) for the %{org_name} was started for you.'),
                         org_name: @template.org.name)
        # rubocop:disable Layout/LineLength
        body = format(_('An administrator from the %{org_name} has started a new data management plan (DMP) for you. If you have any questions or need help, please contact them at %{org_admin_email}.'),
                      org_name: @template.org.name,
                      org_admin_email: helpers.link_to(
                        @template.org.contact_email, @template.org.contact_email
                      ))
        # rubocop:enable Layout/LineLength

        @template.email_subject = subject if @template.email_subject.blank?
        @template.email_body = body if @template.email_body.blank?

        render '/org_admin/templates/email' # .js.erb'
      end
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/AbcSize
      def preferences
        template = Template.find(params[:id])
        authorize Template

        editable = template.latest? && template.id.present? && template.org_id = current_user.org.id
        page = editable ? 'preferences' : 'preferences_show'

        render page, locals: {
          partial_path: 'edit',
          template: template,
          output_types: ResearchOutput.output_types,
          preferred_licenses: License.preferred.map { |license| [license.identifier, license.id] },
          licenses: License.selectable.map { |license| [license.identifier, license.id] }
        }
      end
      # rubocop:enable Metrics/AbcSize

      # GET /org_admin/templates/[:id] # ,
      # rubocop:disable Metrics/AbcSize
      def save_preferences
        template = Template.find(params[:id])
        authorize Template

        args = preference_params
        args[:customize_output_types] = params[:customize_output_types_sel] != '0'
        args[:customize_licenses] = params[:customize_licenses_sel] != '0'

        Template.transaction do
          # Get the current template or a new version if applicable
          @template = get_modifiable(template)
          @template.update(template_output_types: [], licenses: [], repositories: [], customized_repositories: [],
                           metadata_standards: [])
          @template.update(args)
          @template.update(repositories: []) if preference_params[:customize_repositories] == '0'
          @template.update(metadata_standards: []) if preference_params[:customize_metadata_standards] == '0'
        rescue StandardError => e
          Rails.logger.error "Unable to save the Template preferences for #{template.id} - #{e.message}"
          # rubocop:disable Layout/LineLength
          redirect_to preferences_org_admin_template_path(template), alert: failure_message(@template, _('save')) and return
          # rubocop:enable Layout/LineLength
        end

        redirect_to preferences_org_admin_template_path(@template), notice: success_message(@template, _('saved'))
      end
      # rubocop:enable Metrics/AbcSize

      def define_custom_repository
        @template = Template.find(params[:id])
        authorize Template

        preferences
      end

      # rubocop:disable Metrics/AbcSize
      def repository_search
        @template = Template.find(params[:id])
        authorize Template

        @search_results = Repository.by_type(repo_search_params[:type_filter])
        @search_results = @search_results.by_subject(repo_search_params[:subject_filter])
        @search_results = @search_results.search(repo_search_params[:search_term])

        @search_results = @search_results.order(:name).page(params[:page])
      end
      # rubocop:enable Metrics/AbcSize

      def metadata_standard_search
        @template = Template.find(params[:id])
        authorize Template

        @search_results = MetadataStandard.search(metadata_standard_search_params[:search_term])
                                          .order(:title)
                                          .page(params[:page])
      end

      private

      def repo_search_params
        params.require(:template).permit(%i[search_term subject_filter type_filter])
      end

      def metadata_standard_search_params
        params.require(:template).permit(%i[search_term])
      end

      def preference_params
        params.require(:template).permit(
          :enable_research_outputs,
          :user_guidance_output_types, :user_guidance_repositories,
          :user_guidance_output_types_title, :user_guidance_output_types_description,
          :user_guidance_metadata_standards, :user_guidance_licenses,
          :customize_output_types, :customize_repositories,
          :customize_metadata_standards, :customize_licenses,
          template_output_types_attributes: %i[id research_output_type],
          licenses_attributes: %i[id],
          repositories_attributes: %i[id],
          customized_repositories_attributes: %i[id name description uri],
          metadata_standards_attributes: %i[id]
        )
      end
    end
  end
end
