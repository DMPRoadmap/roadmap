# frozen_string_literal: true

module FeedbacksHelper

  def feedback_confirmation_default_subject
    _("DMP feedback request")
  end

  def feedback_confirmation_default_message
    _("<p>Dear %{user_name},</p>"\
      "<p>\"%{plan_name}\" has been sent to your %{application_name} account administrator for feedback.</p>"\
      "<p>Please email %{organisation_email} with any questions about this process.</p>")
  end

  def feedback_constant_to_text(text, user, plan, org)
    _(text.to_s) % { application_name: ApplicationService.application_name,
                     user_name: user.name(false),
                     plan_name: plan.title,
                     organisation_email: org.contact_email }
  end

end
