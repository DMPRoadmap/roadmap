module Settings
  class Dmptemplate < RailsSettings::SettingObject
  
  #attr_accessible :var, :target, :target_id, :target_type

    VALID_FONT_FACES = [
      'Arial, Helvetica, Sans-Serif',
      '"Times New Roman", Times, Serif'
    ]

    VALID_FONT_SIZE_RANGE = (8..14)
    VALID_MARGIN_RANGE = (5..25)

    VALID_ADMIN_FIELDS = ['project_name', 'project_identifier', 'grant_title', 'principal_investigator',
                          'project_data_contact', 'project_description', 'funder', 'institution']

    DEFAULT_SETTINGS = {
      formatting: {
        margin: { # in millimeters
          top:    20,
          bottom: 20,
          left:   20,
          right:  20
        },
        font_face: VALID_FONT_FACES.first,
        font_size: 12 # pt
      },
      max_pages: 3,
      fields: {
        admin: VALID_ADMIN_FIELDS,
        questions: :all
      },
      title: ""
    }

    validate do
      formatting = value['formatting']
      max_pages  = value['max_pages']
      fields     = value['fields']

      if formatting.present?
        errs = []
        default_formatting = DEFAULT_SETTINGS[:formatting]

        unless (default_formatting.keys - formatting.keys).empty?
          errs << :missing_key
        else
          unless formatting[:margin].is_a?(Hash)
            errs << :invalid_margin
          else
            errs << :negative_margin if formatting[:margin].any? {|k,v| v.to_i < 0 }
            errs << :unknown_margin unless (formatting[:margin].keys - default_formatting[:margin].keys).empty?
            errs << :invalid_margin unless formatting[:margin].all? {|k,v| VALID_MARGIN_RANGE.member?(v) }
          end

          errs << :invalid_font_size unless VALID_FONT_SIZE_RANGE.member?(formatting[:font_size])
          errs << :invalid_font_face unless VALID_FONT_FACES.member?(formatting[:font_face])
          errs << :unknown_key unless (formatting.keys - default_formatting.keys).empty?
        end

        errs.map do |key|
          errors.add(:formatting, I18n.t("helpers.settings.plans.errors.#{key}"))
        end

      end

      if max_pages.present? && (!max_pages.is_a?(Integer) || max_pages <= 0)
        errors.add(:max_pages, I18n.t('helpers.settings.plans.errors.invalid_max_pages'))
      end
    end

    before_validation do
      self.formatting[:font_size] = self.formatting[:font_size].to_i if self.formatting[:font_size].present?
      unless self.formatting[:margin].nil? or (not self.formatting[:margin].is_a?(Hash))
        self.formatting[:margin].each do |key, val|
          self.formatting[:margin][key] = val.to_i
        end
      end

      self.fields.each do |key, val|
        if val.is_a?(Hash)
          val = key == :questions ? val.keys.map {|k| k.to_s.to_i } : val.keys
        end

        self.fields[key] = val
      end

      # Save empty arrays if we don't have any fields for them
      self.fields[:admin] ||= []
      self.fields[:questions] ||= []
    end
  end
end
