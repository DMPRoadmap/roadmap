# frozen_string_literal: true

module FeedbacksHelper

  def feedback_confirmation_default_subject
    _("%{application_name}: Your plan has been submitted for feedback")
  end

  def feedback_confirmation_default_message
    _("<p>Hello %{user_name}.</p>"\
      "<p>Your plan \"%{plan_name}\" has been submitted for feedback from an
      administrator at your organisation. "\
      "If you have questions pertaining to this action, please contact us
      at %{organisation_email}.</p>")
  end

  def feedback_constant_to_text(text, user, plan, org)
    _(text.to_s) % { application_name: ApplicationService.application_name,
                     user_name: user.name(false),
                     plan_name: plan.title,
                     organisation_email: org.contact_email }
  end

end
