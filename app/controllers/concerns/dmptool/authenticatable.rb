# frozen_string_literal: true

module Dmptool
  # DMPTool specific helpers for the sign in / sign up workflows
  # rubocop:disable Metrics/BlockLength
  module Authenticatable
    include OrgSelectable

    extend ActiveSupport::Concern

    included do
      # Modify/Set the incoming params befofe they're loaded into the Strong Params
      before_action :ensure_language, only: %i[create update]
      before_action :humanize_params, only: %i[create update]

      # Convert the selected (or user entered name) into Org params
      before_action :ensure_org_param, only: %i[create update]

      # Determine who the user is based on the email provided
      before_action :fetch_user, only: %i[create update]

      # Assign the default instance variables used by the auth pages
      before_action :assign_instance_variables

      # ==============
      # = PARAMETERS =
      # ==============

      # Acceptable Strong Params for each auth type
      def authentication_params(type:)
        case type.to_sym
        when :sign_up
          [:accept_terms, :email, :firstname, :language_id, :org_id, :password, :surname,
           { org_attributes: %i[abbreviation contact_email contact_name is_other
                                managed name org_type target_url links] }]
        when :sign_in
          %i[email org_id password]
        else
          %i[email]
        end
      end

      # Attempt to determine the Org (or RegistryOrg) based on the email's domain
      # rubocop:disable Metrics/AbcSize
      def org_from_email_domain(email_domain:)
        ignored_email_domains = %w[aol.com duck.com gmail.com example.com example.org
                                   hotmail.com icloud.com outlook.com pm.me qq.com yahoo.com]
        return nil unless email_domain.present?
        return nil if ignored_email_domains.include?(email_domain.downcase)

        org = lookup_registry_org_by_email(email_domain: email_domain)
        return org if org.present?

        hash = ::User.where('email LIKE ?', "%@#{email_domain.downcase}").group(:org_id).count
        return nil unless hash.present?

        selected = hash.select { |_k, v| v == hash.values.max }
        ::Org.find_by(id: selected.keys.first)
      end
      # rubocop:enable Metrics/AbcSize

      # Get the RegistryOrg with the closest matching domain and no Org association
      def lookup_registry_org_by_email(email_domain:)
        return nil unless email_domain.present?

        orgs = ::RegistryOrg.where('LOWER(home_page) LIKE ?', "%#{email_domain.downcase}%")
        return nil unless orgs.any?

        # Get the one with closest match (e.g. http://ucsd.edu instead of
        # http://health.ucsd.edu if the email_domain is 'ucsd.edu')
        orgs = orgs.sort do |a, b|
          l = email_domain.length
          (a.home_page.length - l) <=> (b.home_page.length - l)
        end
        orgs.first.to_org
      end

      # Get the user from any OmniAuth information that is available
      def user_from_omniauth
        IdentifierScheme.for_users.each do |scheme|
          omniauth_hash = session.fetch("devise.#{scheme.name}_data", {})
          next if omniauth_hash.empty?

          return ::User.from_omniauth(scheme_name: scheme.name, omniauth_hash: omniauth_hash)
        end
        nil
      end

      # =============
      # = CALLBACKS =
      # =============

      # Lookup the user based on the email
      # rubocop:disable Metrics/AbcSize
      def fetch_user
        self.resource = ::User.includes(:org, :identifiers)
                              .find_or_initialize_by(email: params[:user][:email])

        # If the User's Org is not defined or they are a super admin (because super
        # admins have the ability to alter their affiliation), try to determine the
        # Org based on their email domain
        #
        # disabling rubocop here as I think this is readable
        # rubocop:disable Style/GuardClause
        if resource.org_id.nil? || resource.can_super_admin?
          resource.org = org_from_email_domain(
            email_domain: resource.email&.split('@')&.last
          )
        end
        # rubocop:enable Style/GuardClause
      end
      # rubocop:enable Metrics/AbcSize

      # Assign the default instance variables used by all the auth pages
      def assign_instance_variables
        @main_class = 'js-heroimage'

        @shibbolized = resource.present? ? resource.org&.shibbolized? : false
      end

      # Capitalize the firstname, surname and the Org name if its user entered
      # rubocop:disable Metrics/AbcSize
      def humanize_params
        up = params.fetch(:user, {})
        params[:user][:firstname] = up[:firstname].humanize if up[:firstname].present?
        params[:user][:surname] = up[:surname].humanize if up[:surname].present?

        op = params.fetch(:org_autocomplete, {})
        # disabling rubocop here as I think this is readable
        # rubocop:disable Style/GuardClause
        if op.present? && op[:user_entered_name].present?
          params[:org_autocomplete][:user_entered_name] = op[:user_entered_name].humanize
        end
        # rubocop:enable Style/GuardClause
      end
      # rubocop:enable Metrics/AbcSize

      # Set the Language to the one the user has selected if possible
      def ensure_language
        # disabling rubocop here as I think this is readable
        # rubocop:disable Style/GuardClause
        unless I18n.locale.nil? || params[:language_id].present?
          params[:user][:language_id] = ::Language.id_for(I18n.locale)
        end
        # rubocop:enable Style/GuardClause
      end

      # Convert the results of the Org Autocomplete into an Org or Org.id
      def ensure_org_param
        # Convert the selected/specified Org name into attributes
        op = autocomplete_to_controller_params
        params[:user][:org_id] = op[:org_id] if op[:org_id].present?
        params[:user][:org_attributes] = op[:org_attributes] unless op[:org_id].present?
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
