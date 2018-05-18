module SettingsTemplateHelper
    # Retrieves an msgstr for a given admin_field
    def admin_field_t(admin_field)
        if Settings::Template::VALID_ADMIN_FIELDS.include?(admin_field)
            if admin_field == 'project_name'
                return _('Plan Name')
            elsif admin_field == 'project_identifier'
                return _('Plan ID')
            elsif admin_field == 'grant_title'
                return _('Grant number')
            elsif admin_field == 'principal_investigator'
                return _('Principal Investigator / Researcher')
            elsif admin_field == 'project_data_contact'
                return _('Plan Data Contact')
            elsif admin_field == 'project_description'
                return _('Plan Description')
            elsif admin_field == 'funder'
                return _('Funder')
            elsif admin_field == 'institution'
                return _('Organisation')
            elsif admin_field == 'orcid'
                return _('Your ORCID')
            end
        end
        return _('Unknown column name.')
    end
end