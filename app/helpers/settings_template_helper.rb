# frozen_string_literal: true

module SettingsTemplateHelper

  # Retrieves an msgstr for a given admin_field
  def admin_field_t(admin_field)
    return _("Unknown column name.") if Settings::Template::VALID_ADMIN_FIELDS.include?(admin_field)
    return _("Plan Name") if admin_field == "project_name"
    return _("Plan ID") if admin_field == "project_identifier"
    return _("Grant number") if admin_field == "grant_title"
    return _("Principal Investigator / Researcher") if admin_field == "principal_investigator"
    return _("Plan Data Contact") if admin_field == "project_data_contact"
    return _("Plan Description") if admin_field == "project_description"
    return _("Funder") if admin_field == "funder"
    return _("Organisation") if admin_field == "institution"
    return _("Your ORCID") if admin_field == "orcid"

    _("Unknown column name.")
  end
  # rubocop:enable

end
