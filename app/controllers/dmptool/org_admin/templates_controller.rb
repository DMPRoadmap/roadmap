# frozen_string_literal: true

module Dmptool

  module OrgAdmin

    module TemplatesController

      # GET /org_admin/templates/132/email (AJAX)
      #------------------------------------------
      def email
        @template = Template.find_by(id: params[:id])
        authorize @template

        subject = _("A new data management plan (DMP) for the %{org_name} was created for you.") % {
          org_name: @template.org.name
        }
        body = _("An administrator from the %{org_name} has created a new data management plan (DMP) for you. If you have any questions or need help, please contact them at %{org_admin_email}.") % {
          org_name: @template.org.name,
          org_admin_email: @template.org.contact_email
        }

        @template.email_subject = subject unless @template.email_subject.present?
        @template.email_body = body unless @template.email_body.present?
      end

    end

  end

end
