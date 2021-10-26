# frozen_string_literal: true

# == Schema Information
#
# Table name: settings
#
#  id          :integer          not null, primary key
#  target_type :string           not null
#  value       :text
#  var         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  target_id   :integer          not null
#

module Settings

  class Template < RailsSettings::SettingObject

    VALID_FONT_FACES = [
      '"Times New Roman", Times, Serif',
      "Arial, Helvetica, Sans-Serif"
    ].freeze

    VALID_FONT_SIZE_RANGE = (8..14).freeze
    VALID_MARGIN_RANGE = (5..25).freeze

    VALID_ADMIN_FIELDS = %w[project_name project_identifier grant_title
                            principal_investigator project_data_contact
                            project_description funder institution orcid].freeze

    VALID_FORMATS = %w[csv html pdf text docx json].freeze

    DEFAULT_SETTINGS = {
      formatting: {
        margin: {
          top: 25,
          bottom: 20,
          left: 12,
          right: 12
        },
        font_face: "Arial, Helvetica, Sans-Serif",
        font_size: 10 # pt
      },
      max_pages: 3,
      fields: {
        admin: VALID_ADMIN_FIELDS,
        questions: :all
      },
      title: ""
    }.freeze

    # rubocop:disable Metrics/BlockLength, Metrics/BlockNesting
    validate do
      formatting = value["formatting"]
      max_pages  = value["max_pages"]

      if formatting.present?
        errs = []
        default_formatting = DEFAULT_SETTINGS[:formatting]

        if (default_formatting.keys - formatting.keys).empty?
          if formatting[:margin].is_a?(Hash)
            errs << :negative_margin if formatting[:margin].any? { |_k, v| v.to_i.negative? }
            unless (formatting[:margin].keys - default_formatting[:margin].keys).empty?
              errs << :unknown_margin
            end
            unless formatting[:margin].all? { |_k, v| VALID_MARGIN_RANGE.member?(v) }
              errs << :invalid_margin
            end
          else
            errs << :invalid_margin
          end

          errs << :invalid_font_size unless VALID_FONT_SIZE_RANGE.member?(formatting[:font_size])
          errs << :invalid_font_face unless VALID_FONT_FACES.member?(formatting[:font_face])
          errs << :unknown_key unless (formatting.keys - default_formatting.keys).empty?
        else
          errs << :missing_key
        end

        errs.map do |key|
          if key == :missing_key
            errors.add(:formatting, _("A required setting has not been provided"))
          elsif key == :invalid_margin
            errors.add(:formatting, _("Margin value is invalid"))
          elsif key == :negative_margin
            errors.add(:formatting, _("Margin cannot be negative"))
          elsif key == :unknown_margin
            # rubocop:disable Layout/LineLength
            errors.add(:formatting, _("Unknown margin. Can only be 'top', 'bottom', 'left' or 'right'"))
            # rubocop:enable Layout/LineLength
          elsif key == :invalid_font_size
            errors.add(:formatting, _("Invalid font size"))
          elsif key == :invalid_font_face
            errors.add(:formatting, _("Invalid font face"))
          elsif key == :unknown_key
            errors.add(:formatting, _("Unknown formatting setting"))
          end
        end

      end

      if max_pages.present? && (!max_pages.is_a?(Integer) || max_pages <= 0)
        errors.add(:max_pages, _("Invalid maximum pages"))
      end
    end
    # rubocop:enable Metrics/BlockLength, Metrics/BlockNesting

    before_validation do
      formatting[:font_size] = formatting[:font_size].to_i if formatting[:font_size].present?
      unless formatting[:margin].nil? or !formatting[:margin].is_a?(Hash)
        formatting[:margin].each do |key, val|
          formatting[:margin][key] = val.to_i
        end
      end

      fields.each do |key, val|
        if val.is_a?(Hash)
          val = key == :questions ? val.keys.map { |k| k.to_s.to_i } : val.keys
        end

        fields[key] = val
      end

      # Save empty arrays if we don't have any fields for them
      fields[:admin] ||= []
      fields[:questions] ||= []
    end

  end

end
