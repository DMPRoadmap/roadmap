# frozen_string_literal: true

<<<<<<< HEAD
class ContributorPresenter

  class << self

    # Returns the name with each word capitalized
    def display_name(name:)
      return "" unless name.present?

      name.split.map(&:capitalize).join(" ")
=======
# Helper class for the Contributor pages
class ContributorPresenter
  class << self
    # Returns the name with each word capitalized
    def display_name(name:)
      return '' unless name.present?

      name.split.map(&:capitalize).join(' ')
>>>>>>> upstream/master
    end

    # Returns the string name for each role
    def display_roles(roles:)
<<<<<<< HEAD
      return "None" unless roles.present? && roles.any?

      roles.map { |role| role_symbol_to_string(symbol: role) }.join("<br/>").html_safe
=======
      return 'None' unless roles.present? && roles.any?

      roles.map { |role| role_symbol_to_string(symbol: role) }.join('<br/>').html_safe
>>>>>>> upstream/master
    end

    # Fetches the contributor's ORCID or initializes one
    def orcid(contributor:)
<<<<<<< HEAD
      orcid = contributor.identifier_for_scheme(scheme: "orcid")
      return orcid if orcid.present?

      scheme = IdentifierScheme.by_name("orcid").first
=======
      orcid = contributor.identifier_for_scheme(scheme: 'orcid')
      return orcid if orcid.present?

      scheme = IdentifierScheme.by_name('orcid').first
>>>>>>> upstream/master
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
<<<<<<< HEAD
        _("Data Manager")
      when :project_administration
        _("Project Administrator")
      when :investigation
        _("Principal Investigator")
      else
        _("Other")
=======
        _('Data Manager')
      when :project_administration
        _('Project Administrator')
      when :investigation
        _('Principal Investigator')
      else
        _('Other')
>>>>>>> upstream/master
      end
    end

    # rubocop:disable Layout/LineLength
    def role_tooltip(symbol:)
      case symbol
      when :data_curation
<<<<<<< HEAD
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

=======
        _('Management activities to annotate (produce metadata), scrub data and maintain research data (including software code, where it is necessary for interpreting the data itself) for initial use and later re-use.')
      when :investigation
        _('Conducting a research and investigation process, specifically performing the experiments, or data/evidence collection.')
      when :project_administration
        _('Management and coordination responsibility for the research activity planning and execution.')
      else
        ''
      end
    end
    # rubocop:enable Layout/LineLength
  end
>>>>>>> upstream/master
end
