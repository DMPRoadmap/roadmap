# frozen_string_literal: true

# Provides methods to handle the org_id hash returned to the controller
# for pages that use the Org selection autocomplete widget
module OrgSelectable

  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do

    private

    # Converts the incoming params_into an Org by either locating it
    # via its id, identifier and/or name, or initializing a new one
    def org_from_params(params_in:, allow_create: true)
      params_in = params_in.with_indifferent_access
      return nil unless params_in[:org_id].present? &&
                        params_in[:org_id].is_a?(String)

      hash = org_hash_from_params(params_in: params_in)
      return nil unless hash.present?

      org = OrgSelection::HashToOrgService.to_org(hash: hash,
                                                  allow_create: allow_create)
      allow_create ? create_org(org: org, params_in: params_in) : org
    end

    # Converts the incoming params_into an array of Identifiers
    def identifiers_from_params(params_in:)
      params_in = params_in.with_indifferent_access
      return [] unless params_in[:org_id].present? &&
                       params_in[:org_id].is_a?(String)

      hash = org_hash_from_params(params_in: params_in)
      return [] unless hash.present?

      OrgSelection::HashToOrgService.to_identifiers(hash: hash)
    end

    # Remove the extraneous Org Selector hidden fields so that they don't get
    # passed on to any save methods
    def remove_org_selection_params(params_in:)
      params_in.delete(:org_id)
      params_in.delete(:org_name)
      params_in.delete(:org_sources)
      params_in.delete(:org_crosswalk)
      params_in
    end

    # Just does a JSON parse of the org_id hash
    def org_hash_from_params(params_in:)
      JSON.parse(params_in[:org_id]).with_indifferent_access
    rescue JSON::ParserError => e
      Rails.logger.error "Unable to parse Org Selection JSON: #{e.message}"
      Rails.logger.error params_in.inspect
      {}
    end

    # Saves the org if its a new record
    def create_org(org:, params_in:)
      return org unless org.present? && org.new_record?

      # Save the Org before attaching identifiers
      org.save
      identifiers_from_params(params_in: params_in).each do |identifier|
        next unless identifier.value.present?

        identifier.identifiable = org
        identifier.save
      end
      org.reload
    end

  end
  # rubocop:enable Metrics/BlockLength

end
