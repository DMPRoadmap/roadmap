# frozen_string_literal: true

class ContributorPresenter

  class << self

    # Returns the name with each word capitalized
    def display_name(name:)
      return "" unless name.present?

      name.split.map(&:capitalize).join(" ")
    end

    # Returns the string name for each role
    def display_roles(roles:)
      return "None" unless roles.present? && roles.any?

      roles.map { |role| role_symbol_to_string(symbol: role) }.join("<br/>").html_safe
    end

    # Fetches the contributor's ORCID or initializes one
    def orcid(contributor:)
      orcid = contributor.identifier_for_scheme(scheme: "orcid")
      return orcid if orcid.present?

      scheme = IdentifierScheme.by_name("orcid").first
      return nil unless scheme.present?

      Identifier.new(identifiable: contributor, identifier_scheme: scheme)
    end

    def roles_for_radio(contributor:)
      all_roles = Contributor.new.all_roles
      return all_roles unless contributor.present?

      selected = contributor.selected_roles
      all_roles.map { |role| { "#{role}": selected.include?(role) } }
    end

    def role_symbol_to_string(symbol:)
      case symbol
      when :data_curation
        "Data Manager"
      when :project_administration
        "Project Administrator"
      else
        "Principal Investigator"
      end
    end

    # rubocop:disable Layout/LineLength
    def role_tooltip(symbol:)
      case symbol
      when :data_curation
        _("Management activities to annotate (produce metadata), scrub data and maintain research data (including software code, where it is necessary for interpreting the data itself) for initial use and later re-use.")
      when :investigation
        _("Conducting a research and investigation process, specifically performing the experiments, or data/evidence collection.")
      when :project_administration
        _("Management and coordination responsibility for the research activity planning and execution.")
      else
        ""
      end
    end
    # rubocop:enable Layout/LineLength

  end

end
