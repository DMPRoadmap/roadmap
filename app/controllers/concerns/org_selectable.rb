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
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def autocomplete_to_controller_params(namespace: nil)
      name = name_from_params(namespace: namespace)
      return {} if name.blank?

      # If it matches an existing Org record, just return the org_id
      org = Org.find_by('LOWER(name) = ?', name.downcase)
      return { org_id: org.id } if org.present?

      # If it matches a RegistryOrg and it has an Org association, just return the org_id
      registry_org = RegistryOrg.find_by('LOWER(name) = ?', name.downcase)
      return { org_id: registry_org.org_id } if registry_org.present? &&
                                                registry_org.org_id.present?

      # Return nothing if we are not allowing users to create orgs
      return {} if Rails.configuration.x.application.restrict_orgs &&
                   current_user.blank?
      return {} if Rails.configuration.x.application.restrict_orgs &&
                   (current_user.present? && !current_user.can_super_admin?)

      # If it matches a RegistryOrg convert it to an Org OR initialize a new Org
      org = registry_org.present? ? registry_org.to_org : Org.new(name: name)

      # Special handling for org type based on the namespace
      case namespace&.gsub('_', '')
      when 'funder'
        org.funder = true
        org.institution = false
        org.organisation = false
      end

      org_to_attributes(org: org)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def process_org!(user: nil, managed_only: false, namespace: nil)
      name = name_from_params(namespace: namespace)
      return nil if name.blank?

      # check the Orgs table first
      org = Org.where('LOWER(name) = ?', name.downcase).first
      # If we are expecting managed_only do not return it if it is not managed!
      return org if org.present? && (!managed_only || (managed_only && org.managed?))

      # Skip if restrict_orgs is set to true! (unless its a Super Admin)
      if (user.present? && user.can_super_admin?) || !Rails.configuration.x.application.restrict_orgs
        # fetch from the ror table
        registry_org = RegistryOrg.where('LOWER(name) = ?', name.downcase).first

        # If managed_only make sure the org is managed!
        return nil if managed_only &&
                      (registry_org.nil? || registry_org&.org&.nil? || !registry_org&.org&.managed?)

        # Convert the RegistryOrg to an Org, save it and then update the RegistryOrg if its ok
        org = ::Org.from_registry_org!(registry_org: registry_org)
        return org if org.present?
      end

      # We only want to create it if the user provided a custom name
      return nil if in_list?(namespace: namespace)

      # otherwise initialize a new org
      create_org!(name: name)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # Function very similar to process_org! above but works with requests from the React UI
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def process_react_typeahead(user: nil, search_term:)
      return nil if search_term.blank?

      # check the Orgs table first
      org = Org.where('LOWER(name) = ?', search_term.downcase).first
      # If we are expecting managed_only do not return it if it is not managed!
      return org if org.present? && (!managed_only || (managed_only && org.managed?))

      # Skip if restrict_orgs is set to true! (unless its a Super Admin)
      if (user.present? && user.can_super_admin?) || !Rails.configuration.x.application.restrict_orgs
        # fetch from the ror table
        registry_org = RegistryOrg.where('LOWER(name) = ?', name.downcase).first

        # If managed_only make sure the org is managed!
        return nil if managed_only &&
                      (registry_org.nil? || registry_org&.org&.nil? || !registry_org&.org&.managed?)

        # Convert the RegistryOrg to an Org, save it and then update the RegistryOrg if its ok
        org = ::Org.from_registry_org!(registry_org: registry_org)
        return org if org.present?
      end

      # We only want to create it if the user provided a custom name
      return nil if in_list?(namespace: namespace)

      # otherwise initialize a new org
      create_org!(name: name)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private

    def org_selectable_params
      # Note that any time we create a new namespace (e.g. funder), we need to add the corresponding
      # params to this list below!
      params.permit(org_autocomplete: %i[funder_name funder_not_in_list funder_user_entered_name
                                         name not_in_list user_entered_name])
    end

    # Fetches the appropriate name based on the specified :namespace and whether or not
    # the User supplied a custom Org name
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def name_from_params(namespace: nil)
      o_params = org_selectable_params.fetch(:org_autocomplete, {})
      namespace += '_' unless namespace.nil? || namespace.end_with?('_')
      return o_params["#{namespace}name"] if in_list?(namespace: namespace) &&
                                             o_params["#{namespace}name"].present?

      # If the user entered a custom entry then humanize it and capitalize each word
      o_params["#{namespace}user_entered_name"]&.humanize&.split&.map(&:capitalize)&.join(' ')
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # Determines if the User supplied a custom Org name
    def in_list?(namespace: nil)
      o_params = org_selectable_params.fetch(:org_autocomplete, {})
      namespace += '_' unless namespace.nil? || namespace.end_with?('_')
      o_params["#{namespace}not_in_list"] != '1'
    end

    def org_to_attributes(org:)
      return {} unless org.is_a?(Org)

      {
        org_attributes: {
          name: org.name,
          abbreviation: org.abbreviation || org.name_to_abbreviation,
          contact_email: org.contact_email || ::Org.default_contact_email,
          contact_name: org.contact_name || ::Org.default_contact_name,
          links: org.links || { org: [] },
          target_url: org.target_url,
          is_other: org.is_other?,
          managed: org.managed?,
          org_type: org.org_type
        }
      }
    end

    # Create a new Org
    def create_org!(name:)
      org = ::Org.find_or_initialize_by(name: name)
      return org unless org.new_record?

      org.update(
        abbreviation: org.name_to_abbreviation,
        contact_email: ::Org.default_contact_email,
        contact_name: ::Org.default_contact_name,
        is_other: false,
        managed: false,
        organisation: true
      )
      org
    end
  end
  # rubocop:enable Metrics/BlockLength
end
