module Settings
  class PlanList < RailsSettings::SettingObject

    #attr_accessible :var, :target, :target_type, :target_id
    
    # TODO: can these be taken from somewhere else rather than hard-coded here?
    DEFAULT_COLUMNS = ['name', 'owner', 'shared', 'last_edited']
    ALL_COLUMNS = DEFAULT_COLUMNS + %i( template_owner identifier grant_number principal_investigator data_contact description )

    validate do
      cols = value["columns"]
      if cols.present? # columns can be empty, in which case they revert to defaults
        errors.add(:columns, I18n.t("helpers.settings.projects.errors.no_name")) unless cols.member?(:name)
        errors.add(:columns, I18n.t("helpers.settings.projects.errors.duplicate")) unless cols.to_a.uniq == cols
        errors.add(:columns, I18n.t("helpers.settings.projects.errors.unknown")) unless (cols.to_a.uniq & ALL_COLUMNS) == cols.to_a.uniq
      end
    end
  end
end
