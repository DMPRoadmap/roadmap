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
    end
    # rubocop:enable Metrics/AbcSize
  end
end
