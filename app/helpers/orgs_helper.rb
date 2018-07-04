module OrgsHelper

  DEFAULT_EMAIL = '%{organisation_email}'.freeze

  # Tooltip string for Org feedback form.
  #
  # @param org [Org] The current Org we're updating feedback form for.
  # @return [String] The tooltip message
  def tooltip_for_org_feedback_form(org)
    output = <<~TEXT
      Someone will respond to your request within 48 hours. If you have
      questions pertaining to this action please contact us at
      %{email}.
    TEXT
    email = org.contact_email.present? ? org.contact_email : DEFAULT_EMAIL
    _(output % { email: email })
  end

end
