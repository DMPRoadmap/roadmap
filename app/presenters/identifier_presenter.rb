# frozen_string_literal: true

class IdentifierPresenter

  attr_reader :schemes
  attr_reader :identifiable

  def initialize(identifiable:)
    @identifiable = identifiable

    @schemes = load_schemes
  end

  def identifiers
    @identifiable.identifiers
  end

  def id_for_scheme(scheme:)
    @identifiable.identifiers.find_or_initialize_by(identifier_scheme: scheme)
  end

  def scheme_by_name(name:)
    schemes.select { |scheme| scheme.name.downcase == name.downcase }
  end

  def id_for_display(id:, with_scheme_name: true)
    return _("None defined") if id.new_record? || id.value.blank?

    without = id.value_without_scheme_prefix
    return id.value unless without != id.value && !without.starts_with?("http")

    "<a href=\"#{id.value}\" class=\"has-new-window-popup-info\"> " +
      "#{with_scheme_name ? id.identifier_scheme.description : ""}: #{without}</a>"
  end

  private

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def load_schemes
    # Load the schemes for the current context
    schemes = IdentifierScheme.for_orgs if @identifiable.is_a?(Org)
    schemes = IdentifierScheme.for_plans if @identifiable.is_a?(Plan)
    schemes = IdentifierScheme.for_users if @identifiable.is_a?(User)
    return [] unless schemes.present? || schemes.empty?

    schemes = schemes.order(:name)

    # Shibboleth Org identifiers are only for use by installations that have
    # a curated list of Orgs that can use institutional login
    if @identifiable.is_a?(Org) &&
       !Rails.application.config.shibboleth_use_filtered_discovery_service
      schemes = schemes.reject { |scheme| scheme.name.downcase == "shibboleth" }
    end
    schemes
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

end
