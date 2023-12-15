# frozen_string_literal: true

module Users
  # Overrides to Devise's Passwords logic
  class PasswordsController < Devise::PasswordsController
    # GET /resource/password/new
    def new
      # super

      # Specify any classes for the <main> tag of the page
      self.resource = User.new
    end

    # POST /resource/password
    def create
      # Check the email up front so that we redirect the user back to the form with
      # the appropriate error message (Devise sends it to a different page by default)
      user = User.where('LOWER(email) = ?', resource_params[:email].downcase).first
      if user.present?
        super
      else
        redirect_to new_user_password_path, alert: _('No account associated with that email address.')
      end
    end

    # GET /resource/password/edit?reset_password_token=abcdef
    # def edit
    #   super
    # end

    # PUT /resource/password
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def update
      self.resource = resource_class.reset_password_by_token(resource_params)

      yield resource if block_given?

      # The following 3 lines are a DMPTool cusomization of the core Devise code
      # Set the accept_terms flag if the user was asked to accept it
      accepted = params.fetch(:user, {})[:accept_terms]
      resource.accept_terms = true if accepted.present? && accepted == 'true'
      resource.valid?

      if resource.errors.empty?
        resource.unlock_access! if unlockable?(resource)
        if Devise.sign_in_after_reset_password
          flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
          set_flash_message!(:notice, flash_message)
          resource.after_database_authentication
          sign_in(resource_name, resource)
        else
          set_flash_message!(:notice, :updated_not_active)
        end
        respond_with resource, location: after_resetting_password_path_for(resource)
      else
        set_minimum_password_length
        respond_with resource
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    protected

    def after_resetting_password_path_for(_resource)
      # super(resource)
      plans_path
    end

    # The path used after sending reset password instructions
    def after_sending_reset_password_instructions_path_for(_resource_name)
      # super(resource_name)
      root_path
    end
  end
end
