# frozen_string_literal: true

module OrgsHelper

  EMAIL_PLACEHOLDER = "[Organisation Contact Email Placeholder]"

  # Sample message for Org feedback form.
  #
  # org - The current Org we're updating feedback form for.
  #
  # Returns String
  def sample_message_for_org_feedback_form(org)
    email = org.contact_email || EMAIL_PLACEHOLDER
    _("<p>A data librarian from %{org_name} will respond to your request within 48
       hours. If you have questions pertaining to this action please contact us
       at %{organisation_email}.</p>") % {
         organisation_email: email,
         org_name: org.name
       }
  end

  # The preferred logo url for the current configuration. If DRAGONFLY_AWS is true, return
  # the remote_url, otherwise return the url
  def logo_url_for_org(org)
    if ENV["DRAGONFLY_AWS"] == "true"
      org.logo.remote_url
    else
      org.logo.url
    end
  end

end
