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

  desc "Set the DMPTool guidance group as the default"
  task set_default_guidance_group: :environment do
    org = Org.where("LOWER(name) LIKE ?", "dmptool%").first
    p "No DMPTool org found!" unless org.present?
    p "Setting '#{org.name}' GuidanceGroup as the default" if org.present?
    GuidanceGroup.where(org_id: org.id).update(is_default: true) if org.present?
  end

end
