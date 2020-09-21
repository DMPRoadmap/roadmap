# frozen_string_literal: true

module ValidationMessages

  # workaround for errors thrown by puma when eager loading application
  # TODO: see if this is still a problem with translations gem
  # I18n.add_text_domain "app", path: "config/locale", type: :po,
  #                                    ignore_fuzzy: true, report_warning: true
  # I18n.text_domain = "app"

  PRESENCE_MESSAGE = _("can't be blank")

  UNIQUENESS_MESSAGE = _("must be unique")

  INCLUSION_MESSAGE = _("isn't a valid value")

  OPTION_PRESENCE_MESSAGE = _("You must have at least one option with accompanying text.")

  QUESTION_TEXT_PRESENCE_MESSAGE = _("for 'Question text' can't be blank.")

end
