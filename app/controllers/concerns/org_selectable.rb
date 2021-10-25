# frozen_string_literal: true

# Provides methods to handle the org_id hash returned to the controller
# for pages that use the Org selection autocomplete widget
#
# This Concern handles the incoming params from a page that has one of the
# Org Typeahead boxes found in app/views/shared/org_selectors/.
#
# The incoming hash looks like this:
#  {
#    "org_name"=>"Portland State University (PDX)",
#    "org_sources"=>"[
#      \"3E (Belgium) (3e.eu)\",
#      \"etc.\"
#    ]",
#    "org_crosswalk"=>"[
#      {
#        \"id\":1574,
#        \"name\":\"3E (Belgium) (3e.eu)\",
#        \"sort_name\":\"3E\",
#        \"ror\":\"https://ror.org/03d33vh19\"
#      },
#     {
#       "etc."
#    }]",
#    "id"=>"{
#      \"id\":62,
#      \"name\":\"Portland State University (PDX)\",
#      \"sort_name\":\"Portland State University\",
#      \"ror\":\"https://ror.org/00yn2fy02\",
#      \"fundref\":\"https://doi.org/10.13039/100007083\"
#    }
#  }
#
# The :org_name, :org_sources, :org_crosswalk are all relics of the JS involved in
# handling the request/response from OrgsController#search AJAX action that is
# used to search both the local DB and the ROR API as the user types.
#   :org_name = the value the user has types in
#   :org_sources = the pick list of Org names returned by the OrgsController#search action
#   :org_crosswalk = all of the info about each Org returned by the OrgsController#search action
#                    there is JS that takes the value in :org_name and then sets the :id param
#                    to the matching Org in the :org_crosswalk on form submission
#
# They are typically removed from the incoming params hash prior to doing a :save or :update
# by the :remove_org_selection_params below.
# TODO: Consider adding a JS method that strips those 3 params out prior to form submission
#       since we only need the contents of the :id param here
#
# The contents of :id are then used to either Create or Find the Org from the DB.
# if id: { :id } is present then the Org was one pulled from the DB. If it is not
# present then it is one of the following:
#  if :ror or :fundref are present then it was one retrieved from the ROR API
#  otherwise it is a free text value entered by the user
#
# See the comments on OrgsController#search for more info on how the typeaheads work
module OrgSelectable

  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    before_action :prep_org_partial

    private

    # Converts the incoming params_into an Org by either locating it
    # via its id, identifier and/or name, or initializing a new one
    def org_from_params(params_in:, allow_create: true)
      # params_in = params_in.with_indifferent_access
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
      # params_in = params_in.to_h.with_indifferent_access
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
      JSON.parse(params_in[:org_id]) # .with_indifferent_access
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

    def prep_org_partial
      name = Rails.configuration.x.application.restrict_orgs ? "local_only" : "combined"
      @org_partial = "shared/org_selectors/#{name}"
      @all_orgs = Org.includes(identifiers: [:identifier_scheme]).all
    end
  end
  # rubocop:enable Metrics/BlockLength

end
