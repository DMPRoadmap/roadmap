# frozen_string_literal: true

module OrgsHelper

  DEFAULT_EMAIL = '%{organisation_email}'

  # Tooltip string for Org feedback form.
  #
  # org - The current Org we're updating feedback form for.
  #
  # Returns String
  def tooltip_for_org_feedback_form(org)
    email = org.contact_email.presence || DEFAULT_EMAIL
    _("SAMPLE MESSAGE: A data librarian from %{org_name} will respond to your request within 48
       hours. If you have questions pertaining to this action please contact us
       at %{organisation_email}.") % {
      organisation_email: email,
      org_name: org.name
    }
  end
end
