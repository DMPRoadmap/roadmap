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

    # Converts the incoming org_autocomplete params into Org params
    def autocomplete_to_controller_params
      o_params = org_selectable_params.fetch(:org_autocomplete, {})
      not_in_list = o_params["not_in_list"] == "1"
      name = o_params["user_entered_name"]&.humanize if not_in_list
      name = o_params["name"] unless name.present?
      return {} unless name.present?

      # If it matches an existing Org record, just return the org_id
      org = Org.find_by("LOWER(name) = ?", name.downcase)
      return { org_id: org.id } if org.present?

      # If it matches a RegistryOrg and it has an Org association, just return the org_id
      registry_org = RegistryOrg.find_by("LOWER(name) = ?", name.downcase)
      return { org_id: registry_org.org_id } if registry_org.present? &&
                                                registry_org.org_id.present?

      # Return nothing if we are not allowing users to create orgs
      return {} if Rails.configuration.x.application.restrict_orgs &&
                   !current_user.present?
      return {} if Rails.configuration.x.application.restrict_orgs &&
                   (current_user.present? && !current_user.can_super_admin?)

      # If it matches a RegistryOrg convert it to an Org OR initialize a new Org
      org = registry_org.to_org if registry_org.present?
      org = Org.new(name: name) unless org.present?

      {
        org_attributes: {
          name: org.name,
          abbreviation: org.abbreviation || org.name_to_abbreviation,
          contact_email: org.contact_email || Rails.configuration.x.organisation.helpdesk_email,
          contact_name: org.contact_name || _("%{app_name} helpdesk") % { app_name: ApplicationService.application_name },
          links: org.links || { "org": [] },
          target_url: org.target_url,
          is_other: org.is_other?,
          managed: org.managed?,
          org_type: org.org_type
        }
      }
    end

    def process_org!(user: nil, managed_only: false, namespace: nil)
      name = contextualized_name(namespace: namespace)
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
      o_parms = org_selectable_params.fetch(:org_autocomplete, {})
      return nil unless o_params[:"#{user_provided}"].present?

      # otherwise initialize a new org
      create_org!(name: name)
    end

    private

    def org_selectable_params
      # Note that any time we create a new namespace (e.g. funder), we need to add the corresponding
      # params to this list below!
      params.permit(org_autocomplete: %i[crosswalk funder_name funder_not_in_list
                                         funder_user_entered_name name not_in_list
                                         user_entered_name])
    end

    # Add namespace to the incoming name
    def contextualized_name(namespace: "")
      o_params = org_selectable_params.fetch(:org_autocomplete, {})
      user_provided = "#{[namespace, "user_entered_name"].compact.join("_")}"
      name = o_params[:"#{user_provided}"]
      name = o_params[:"#{[namespace, "name"].compact.join("_")}"] unless name.present?
      name
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
