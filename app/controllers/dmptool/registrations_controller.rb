# frozen_string_literal: true

module Dmptool

  module RegistrationsController

    include Dmptool::HomeController

    MSG_BAD_ACCEPT_TERMS = _("You must accept the terms and conditions!").freeze
    MSG_BAD_RECAPTCHA = _("Invalid security check!").freeze

    # POST /users (via UJS form_with)
    def create
      @errors = validate_sign_up_data
      params_to_resource
      @user = resource

pp "IN CONTROLLER:"
pp @user.inspect

      # If the user is new and no errors were encountered and it saves
      if resource.new_record? && resource.valid? && @errors.empty? && resource.save
        sign_up(resource_name, resource)

        # Sign in and render the user's dashboard
        # set_flash_message :notice, :signed_up if is_navigational_format?
        # redirect_to plans_path
      else
        # Something was wrong with the user's input so render the errors
        @errors << resource.errors.full_messages
        @errors = @errors.flatten.uniq
        # Swap out 'Org' for 'Institution' so it matches the language on the form
        @errors = @errors.map do |err|
          err.start_with?("Org") ? err.gsub("Org", "Institution") : err
        end

p "FAILED!"

        # There were errors, so just rerender the home page with the context
        # of the current @user info already entered by the User
        flash[:alert] = @errors.join("<br>")
        render_home_page
        # render "home/index" #"sessions/create"
      end
    end

    # PUT /users (via the edit profile page)
    def update

    end

    private

    def org_params
      params.require(:org_autocomplete).permit(:name, :crosswalk, :not_in_list,
                                               :user_entered_name)
    end

    def validate_sign_up_data
      errs = []
      use_recaptcha = Rails.configuration.x.recaptcha.enabled || false

      errs << MSG_BAD_ACCEPT_TERMS unless sign_up_params[:accept_terms] == "1"
      errs << MSG_BAD_RECAPTCHA if (use_recaptcha && !verify_recaptcha(model: resource))
      errs
    end

    # Convert the sign_up_params into a User
    def params_to_resource
      attrs = sign_up_params
      attrs[:org] = org_lookup

      # Use the currently selected language or the default
      attrs[:language_id] = Language.id_for(I18n.locale) if I18n.locale.present?
      attrs[:language_id] = Language.default&.id unless attrs[:language_id].present?

      # Defer to Devise to build the User
      build_resource(attrs)
    end

    # Convert the incoming Org Autocomplete hash into an Org
    def org_lookup
      # Try to find a ROR Org by its name
      ror = RegistryOrg.find_by(name: org_params[:name]) if org_params[:name].present?
      return ror.to_org if ror.present?

      # Try to find a non-ROR Org by its name
      org = Org.find_by(name: org_params[:name]) if org_params[:name].present?
      return org if org.present?

      # Just double check to make sure its not a known RegistryOrg!
      ror = RegistryOrg.find_by(name: org_params[:user_entered_name])
      return ror.to_org if ror.present?

      # Its a new Org, so initialize it
      Org.initialize_from_org_autocomplete(name: org_params[:user_entered_name])
    end

    # =====================================================
    # = CALLBACKS - tied into the RegistrationsController =
    # =====================================================

    # Extract OAuth variables
    def check_oauth
      IdentifierScheme.for_users.each do |scheme|
        unless session["devise.#{scheme.name.downcase}_data"].nil?
          @oauth_params = session["devise.#{scheme.name.downcase}_data"]
        end
      end
      @oauth_params = @oauth_params.with_indifferent_access if @oauth_params.is_a?(Hash)
    end

  end

end
