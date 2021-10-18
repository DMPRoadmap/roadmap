# frozen_string_literal: true

# DMPTool specific Rake tasks
namespace :dmptool_specific do

  # We sent the maDMP PRs over to DMPRoadmap after they had been live in DMPTool for some time
  # This script moves the re3data URLs which we original stored in the :identifiers table
  # over to the repositories.uri column
  desc "Moves the re3data ids from :identifiers to :repositories.uri"
  task transfer_re3data_ids: :environment do
    re3scheme = IdentifierScheme.find_by(name: "rethreedata")
    if re3scheme.present?
      Identifier.by_scheme_name(re3scheme, "Repository").each do |identifier|
        repository = identifier.identifiable
        if repository.present? && identifier.value.present?
          repository.update(uri: identifier.value)
        end
        identifier.destroy
      end
    end
  end

  desc "Update Feedback confirmation email defaults"
  task update_feedback_confirmation: :environment do
    new_subject = "DMP feedback request"
    old_subject = "%{application_name}: Your plan has been submitted for feedback"

    new_body = "<p>Dear %{user_name},</p>" \
      "<p>\"%{plan_name}\" has been sent to your %{application_name} account administrator for feedback.</p>"\
      "<p>Please email %{organisation_email} with any questions about this process.</p>"
    old_body = "<p>Hello %{user_name}.</p>"\
      "<p>Your plan \"%{plan_name}\" has been submitted for feedback from an
      administrator at your organisation. "\
      "If you have questions pertaining to this action, please contact us
      at %{organisation_email}.</p>"

    Org.all.each do |org|
      org.feedback_email_subject = new_subject if org.feedback_email_subject == old_subject
      org.feedback_email_msg = new_body if org.feedback_email_msg == old_body
      org.save
    end
  end

  desc "Adds the UCNRS RAMS IdentifierScheme for Plans"
  task init_rams: :environment do
    rams = IdentifierScheme.find_or_initialize_by(name: "rams")
    rams.for_plans = true
    rams.for_identification = true
    rams.description = "UCNRS RAMS System"
    rams.identifier_prefix = "https://rams.ucnrs.org/manager/reserves/100501/applications/"
    rams.active = true
    rams.save
  end

  desc "Initialize the Template email subject and body"
  task init_template_emails: :environment do
    Template.published.where(email_body: nil).each do |template|
      template.update(
        email_subject: _("A new data management plan (DMP) for the %{org_name} was started for you.") % {
          org_name: template.org.name
        },
        email_body: _("An administrator from the %{org_name} has started a new data management plan (DMP) for you. If you have any questions or need help, please contact them at %{org_admin_email}.") % {
          org_name: template.org.name,
          org_admin_email: "<a href=\"mailto:#{template.org.contact_email}\">#{template.org.contact_email}</a>"
        }
      )
    end
  end

end
