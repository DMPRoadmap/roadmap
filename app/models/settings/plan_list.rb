module Settings
  class PlanList < RailsSettings::SettingObject

    #attr_accessible :var, :target, :target_type, :target_id
    
    # TODO: can these be taken from somewhere else rather than hard-coded here?
    DEFAULT_COLUMNS = ['name', 'owner', 'shared', 'last_edited']
    ALL_COLUMNS = DEFAULT_COLUMNS + ['template_owner', 'identifier', 'grant_number', 'visibility',
                                     'principal_investigator', 'data_contact', 'description']

    validate do
      cols = value["columns"]

      if cols.present? # columns can be empty, in which case they revert to defaults
        errors.add(:columns, _("'name' must be included in column list.")) unless cols.member?("name")
        errors.add(:columns, _('Duplicate column name. Please only include each column once.')) unless cols.keys.uniq == cols.keys
        errors.add(:columns, _('Unknown column name.')) unless (cols.keys.uniq & ALL_COLUMNS) == cols.keys.uniq
      end
    end
  end
end
