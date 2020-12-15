# frozen_string_literal: true

module SuperAdmin

  module Orgs

    module MergeHelper

      def org_column_content(attributes:)
        return "No mergeable attributes" unless attributes.present? && attributes.keys.any?

        html = "<ul>"
        attributes.each_key do |key|
          html += "<li><strong>#{key}</strong>: #{attributes[key]}</li>"
        end
        "#{html}</ul>"
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def column_content(entries:, orcid:)
        return _("None") unless entries.present? && entries.any?

        html = "<ul>"
        entries.each do |entry|
          text = case entry.class.name
                 when "Annotation"
                   [entry.id, entry.text[0..20]].join(" - ")
                 when "Department"
                   [entry.id, entry.name].join(" - ")
                 when "Guidance"
                   _("Guidance for: %{themes}") % {
                     themes: entry.themes.collect(&:title).join(", ")
                   }
                 when "Identifier"
                   [entry.identifier_scheme&.name, entry.value].join(" - ")
                 when "TokenPermissionType"
                   entry.token_type.capitalize
                 when "Tracker"
                   entry.code
                 when "User"
                   [entry.email, entry.identifier_for_scheme(scheme: orcid)&.value].compact
                                                                                   .join(" - ")
                 else
                   [entry.id, entry.title].join(" - ")
                 end
          html += "<li>#{text}</li>"
        end
        "#{html}</ul>"
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def merge_column_content(entries:, orcid:, to_org_name:)
        return _("Nothing to merge") unless entries.present? && entries.any?

        html = _("<p>The following %{object_types} will be moved over to '%{org_name}':</p>") % {
          object_types: entries.first.class.name.pluralize,
          org_name: to_org_name
        }
        html + column_content(entries: entries, orcid: orcid)
      end

    end

  end

end
