# frozen_string_literal: true

# Provides methods to handle the org_autocomplete params returned to the controller
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
# If you need more than one autocomplete on your page, you can specify a :namespace. The
# namespace (e.g. "funder") must be passed to the _org_autocomplete partial as well as to
# the :process_org! function below.
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

    def process_org!(user: nil, managed_only: false, namespace: nil)
      user_provided = "#{[namespace, "user_entered_name"].compact.join("_")}"
      name = org_selectable_params[:"#{user_provided}"]
      name = org_selectable_params[:"#{[namespace, "name"].compact.join("_")}"] unless name.present?
      return nil unless name.present?

      # check the Orgs table first
      org = Org.where("LOWER(name) = ?", name.downcase).first
      # If we are expecting managed_only do not return it if it is not managed!
      return org if org.present? && (!managed_only || (managed_only && org.managed?))

      # Skip if restrict_orgs is set to true! (unless its a Super Admin)
      if (user.present? && user.can_super_admin?) || !Rails.configuration.x.application.restrict_orgs
        # fetch from the ror table
        registry_org = RegistryOrg.where("LOWER(name) = ?", name.downcase).first

        # If managed_only make sure the org is managed!
        return nil if managed_only &&
          (registry_org.nil? || registry_org&.org&.nil? || !registry_org&.org&.managed?)

        # Convert the RegistryOrg to an Org, save it and then update the RegistryOrg if its ok
        org = create_org_from_registry_org!(registry_org: registry_org)
        return org if org.present?
      end

      # We only want to create it if the user provided a custom name
      return nil unless org_selectable_params[:"#{user_provided}"].present?

      # otherwise initialize a new org
      create_org!(name: name)
    end

    private

    def org_selectable_params
      # Note that any time we create a new namespace (e.g. funder), we need to add the corresponding
      # params to this list below!
      params.require(:org_autocomplete)
            .permit(%i[name not_in_list user_entered_name
                       funder_name funder_not_in_list funder_user_entered_name
                       crosswalk])
    end

    # Create a new Org
    def create_org!(name:)
      org = Org.find_or_create_by(name: name)
      return org unless org.new_record?

      org.update(
        abbreviation: Org.name_to_abbreviation(name: name),
        contact_email: Rails.configuration.x.organisation.helpdesk_email,
        contact_name: _("%{app_name} helpdesk") % { app_name: ApplicationService.application_name },
        is_other: false,
        managed: false,
        organisation: true
      )
      org
    end

    # Create a new Org from the RegistryOrg entry
    def create_org_from_registry_org!(registry_org:)
      return nil unless registry_org.is_a?(RegistryOrg)
      return registry_org.org if registry_org.org_id.present?

      org = registry_org.to_org
      org.save

      # Attach the identifiers
      %w[fundref ror].each do |scheme_name|
        value = registry_org.send(:"#{scheme_name}_id")
        next unless value.present?

        scheme = IdentifierScheme.by_name(scheme_name).first
        next unless scheme.present?

        Identifier.find_or_create_by(identifier_scheme: scheme, identifiable: org, value: value)
      end

      # Update the original RegistryOrg with the new org's association
      registry_org.update(org_id: org.id)
      org.reload
    end

  end
  # rubocop:enable Metrics/BlockLength

end
