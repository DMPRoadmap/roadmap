module Settings
  class Template < RailsSettings::SettingObject

  #attr_accessible :var, :target, :target_id, :target_type

    VALID_FONT_FACES = [
      '"Times New Roman", Times, Serif',
      'Arial, Helvetica, Sans-Serif'
    ]

    VALID_FONT_SIZE_RANGE = (8..14)
    VALID_MARGIN_RANGE = (5..25)

    VALID_ADMIN_FIELDS = ['project_name', 'project_identifier', 'grant_title', 'principal_investigator',
                          'project_data_contact', 'project_description', 'funder', 'institution', 'orcid']

    DEFAULT_SETTINGS = {
      formatting: {
        margin: { # in millimeters
          top:    10,
          bottom: 10,
          left:   10,
          right:  10
        },
        font_face: VALID_FONT_FACES.first,
        font_size: 10 # pt
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
          if key == :missing_key
            errors.add(:formatting, _('A required setting has not been provided'))
          elsif key == :invalid_margin
            errors.add(:formatting, _('Margin value is invalid'))
          elsif key == :negative_margin
            errors.add(:formatting, _('Margin cannot be negative'))
          elsif key == :unknown_margin
            errors.add(:formatting, _("Unknown margin. Can only be 'top', 'bottom', 'left' or 'right'"))
          elsif key == :invalid_font_size
            errors.add(:formatting, _('Invalid font size'))
          elsif key == :invalid_font_face
            errors.add(:formatting, _('Invalid font face'))
          elsif key == :unknown_key
            errors.add(:formatting, _('Unknown formatting setting'))
          end
        end

      end

      if max_pages.present? && (!max_pages.is_a?(Integer) || max_pages <= 0)
        errors.add(:max_pages, _('Invalid maximum pages'))
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
