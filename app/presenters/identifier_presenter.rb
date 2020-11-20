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

  private

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
       !Rails.configuration.x.shibboleth.use_filtered_discovery_service
      schemes = schemes.reject { |scheme| scheme.name.downcase == "shibboleth" }
    end
    schemes
  end

end
