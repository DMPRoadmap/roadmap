module OrgsHelper
  # frozen_string_literal: true

  DEFAULT_EMAIL = '%{organisation_email}'

  # Tooltip string for Org feedback form.
  #
  # @param org [Org] The current Org we're updating feedback form for.
  # @return [String] The tooltip message
  def tooltip_for_org_feedback_form(org)
    email = org.contact_email.presence || DEFAULT_EMAIL
    _("Someone will respond to your request within 48 hours. If you have \
    questions pertaining to this action please contact us at %{email}") % {
      email: email
    }
  end
end
