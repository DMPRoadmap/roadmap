module ValidationMessages
  # frozen_string_literal: true

  PRESENCE_MESSAGE = _("can't be blank")

  UNIQUENESS_MESSAGE = _("must be unique")

  INCLUSION_MESSAGE = _("isn't a valid value")

  # NOTE: if the logic for org.publishable changes, this must be changed
  PUBLISHABLE_MESSAGE = _("cannot be true for default Org")

  HISTORIC_MESSAGE = _("cannot be true for historic versions")



end
