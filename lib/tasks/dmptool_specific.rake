# frozen_string_literal: true

# DMPTool specific Rake tasks
namespace :dmptool_specific do
  # Fetch the latest code for the dmptool-ui submodule and build the assets
  desc 'Fetches the latest from the dmptool-ui repo (git submodule) and builds it'
  task sync_dmptool_ui: :environment do
    dmptool_ui_path = Rails.root.join('dmptool-ui')
    assets_path = Rails.root.join('dmptool-ui', 'dist', 'ui-assets', '*.jpg')
    p "Fetching latest dmptool-ui code from GitHub ..."
    sh "cd #{dmptool_ui_path} && git pull origin main"
    p "Building assets ..."
    sh "cd #{dmptool_ui_path} npm install && npm run build"
    p "Copying images to Rails' public directory ..."
    sh "cp #{assets_path} #{Rails.root.join('public', 'assets')}"
  end

  # We sent the maDMP PRs over to DMPRoadmap after they had been live in DMPTool for some time
  # This script moves the re3data URLs which we original stored in the :identifiers table
  # over to the repositories.uri column
  desc 'Moves the re3data ids from :identifiers to :repositories.uri'
  task transfer_re3data_ids: :environment do
    re3scheme = IdentifierScheme.find_by(name: 'rethreedata')
    if re3scheme.present?
      Identifier.by_scheme_name(re3scheme, 'Repository').each do |identifier|
        repository = identifier.identifiable
        repository.update(uri: identifier.value) if repository.present? && identifier.value.present?
        identifier.destroy
      end
    end
  end

  desc 'Update Feedback confirmation email defaults'
  task update_feedback_confirmation: :environment do
    new_subject = 'DMP feedback request'
    old_subject = '%<application_name>s: Your plan has been submitted for feedback'

    new_body = '<p>Dear %<user_name>s,</p>' \
               '<p>"%<plan_name>s" has been sent to your %<application_name>s account administrator for feedback.</p>'\
               '<p>Please email %<organisation_email>s with any questions about this process.</p>'
    old_body = '<p>Hello %<user_name>s.</p>'\
      "<p>Your plan \"%<plan_name>s\" has been submitted for feedback from an
      administrator at your organisation. "\
      "If you have questions pertaining to this action, please contact us
      at %<organisation_email>s.</p>"

    Org.all.each do |org|
      org.feedback_email_subject = new_subject if org.feedback_email_subject == old_subject
      org.feedback_email_msg = new_body if org.feedback_email_msg == old_body
      org.save
    end
  end

  desc 'Adds the UCNRS RAMS IdentifierScheme for Plans'
  task init_rams: :environment do
    rams = IdentifierScheme.find_or_initialize_by(name: 'rams')
    rams.for_plans = true
    rams.for_identification = true
    rams.description = 'UCNRS RAMS System'
    rams.identifier_prefix = 'https://rams.ucnrs.org/manager/reserves/100501/applications/'
    rams.active = true
    rams.save
  end

  # rubocop:disable Layout/LineLength
  desc 'Initialize the Template and Org email subject and body'
  task init_template_and_org_emails: :environment do
    p 'Initializing empty Template emails'
    Template.published.where(email_body: nil).each do |template|
      template.update(
        email_subject: format(_('A new data management plan (DMP) for the %<org_name>s was started for you.'),
                              org_name: template.org.name),
        email_body: format(
          _('An administrator from the %<org_name>s has started a new data management plan (DMP) for you. If you have any questions or need help, please contact them at %<org_admin_email>s.'), org_name: template.org.name, org_admin_email: "<a href=\"mailto:#{template.org.contact_email}\">#{template.org.contact_email}</a>"
        )
      )
    end

    p 'Initializing empty Org emails'
    Org.where(managed: true, api_create_plan_email_body: nil).each do |org|
      org.update(
        api_create_plan_email_subject: format(
          _('A new data management plan (DMP) for the %<org_name>s was started for you.'), org_name: org.name
        ),
        api_create_plan_email_body: format(
          _('A new data management plan (DMP) has been started for you by the %<external_system_name>s. If you have any questions or need help, please contact the administrator for the %<org_name>s at %<org_admin_email>s.'), org_name: org.name, org_admin_email: "<a href=\"mailto:#{org.contact_email}\">#{org.contact_email}</a>", external_system_name: '%<external_system_name>s'
        )
      )
    end
  end
  # rubocop:enable Layout/LineLength
end
