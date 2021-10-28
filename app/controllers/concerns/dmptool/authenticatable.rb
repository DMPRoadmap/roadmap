# frozen_string_literal: true

module Dmptool

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
           org_attributes: %i[abbreviation contact_email contact_name is_other links
                              managed name org_type target_url]]
        when :sign_in
          %i[email org_id password]
        else
          %i[email]
        end
      end

      # =============
      # = CALLBACKS =
      # =============

      # Lookup the user based on the email
      def fetch_user
        self.resource = ::User.includes(:org, :identifiers)
                              .find_or_initialize_by(email: params[:user][:email])

        # If the User has an invitation then clear their Org. In order to invite the
        # User we needed a default Org so the Inviter's Org was used
        self.resource.org = nil if resource.valid_invitation?

        # If the User's Org is not defined, try to determine it based on their email
        unless self.resource.org_id.present?
          self.resource.org = org_from_email_domain(
            email_domain: resource.email&.split("@")&.last
          )
        end
      end

      # Assign the default instance variables used by all the auth pages
      def assign_instance_variables
        @main_class = "js-heroimage"

        @shibbolized = resource.present? ? resource.org&.shibbolized? : false
      end

      # Capitalize the firstname, surname and the Org name if its user entered
      def humanize_params
        up = params.fetch(:user, {})
        params[:user][:firstname] = up[:firstname].humanize if up[:firstname].present?
        params[:user][:surname] = up[:surname].humanize if up[:surname].present?

        op = params.fetch(:org_autocomplete, {})
        if op.present? && op[:user_entered_name].present?
          params[:org_autocomplete][:user_entered_name] = op[:user_entered_name].humanize
        end
      end

      # Set the Language to the one the user has selected if possible
      def ensure_language
        unless I18n.locale.nil? || params[:language_id].present?
          params[:user][:language_id] = ::Language.id_for(I18n.locale)
        end
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

end
