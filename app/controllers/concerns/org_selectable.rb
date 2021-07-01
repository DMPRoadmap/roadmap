# frozen_string_literal: true

# Provides methods to handle the org_index params returned to the controller
# for pages that use the Org selection autocomplete widget. The params are at
# the top level of the Param tree and not within the context of the surrounding form!
#
# This Concern handles the incoming params from a page that has one of the
# Org Typeahead boxes found in app/views/shared/_org_autocomplete.html.erb.
#
# The incoming params look like this:
#  {
#    org_index: {
#      name: "Portland State University (PDX)",
#      not_in_list: "0",
#      user_entered_name: ""
#    }
#  }
#
# The user has the option of selecting an Org from the autocomplete list OR checking a box
# to indicate that the Org is NOT in the list and that they have manually typepd it in.
#   :name = the name of the Org they selected from the autocomplete list
#   :not_in_list = the boolean value of the checkbox
#   :user_entered_name = the manually entered name of the Org
#
# In either scenario, a query for the Org occurs.
#   If it is found, then that Org is used.
#   Otherwise a query for a matching OrgIndex is run.
#     If it is found then the corresponding Org is used or a new one is created if it doesn't exist
#     Otherwise a new Org is created from the :user_entered_name value
#
module OrgSelectable

  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do

    def process_org!
      name = org_selectable_params[:user_entered_name]
      name = org_selectable_params[:name] unless name.present?
      return nil unless name.present?

      # check the Orgs table first
      org = Org.where("LOWER(name) = ?", name.downcase).first
      return org if org.present?

      # fetch from the ror table
      org_index = OrgIndex.where("LOWER(name) = ?", name.downcase).first
      if org_index.present?
        # Convert the OrgIndex to an Org, save it and then update the OrgIndex
        org = org_index.to_org
        org.save

        persist_identifiers(org_index: org_index, org: org)

        org_index.update(org_id: org.id)
        return org.reload
      end

      # We only want to create it if the user clicked the 'not in list' checkbox
      return nil unless org_selectable_params[:user_entered_name].present?

      # otherwise create a new org
      Org.create(
        name: name,
        abbreviation: Org.name_to_abbreviation(name: name),
        contact_email: Rails.configuration.x.organisation.helpdesk_email,
        contact_name: _("%{app_name} helpdesk") % { app_name: ApplicationService.application_name },
        is_other: false,
        managed: false,
        users_count: 0,
        organisation: true
      )
    end

    # Remove the fields that may have come through in the form submission that were only
    # necessary to facilitate the Org autocomplete's AJAX based suggestions
    def remove_org_selection_params(args:)
      args.delete(:org_crosswalk)
      args
    end

    private

    def org_selectable_params
      params.require(:org_index).permit(%i[name not_in_list user_entered_name])
    end

    def persist_identifiers(org_index:, org:)
      return org unless org_index.present? && org.is_a?(Org)

      fundref_scheme = IdentifierScheme.by_name('fundref').first
      ror_scheme = IdentifierScheme.by_name('ror').first

      if org_index.fundref_id.present? && fundref_scheme.present?
        Identifier.create(identifiable: org, identifier_scheme: fundref_scheme, value: org_index.fundref_id)
      end

      if org_index.ror_id.present? && ror_scheme.present?
        Identifier.create(identifiable: org, identifier_scheme: ror_scheme, value: org_index.ror_id)
      end

      org.reload
    end
  end
  # rubocop:enable Metrics/BlockLength

end
