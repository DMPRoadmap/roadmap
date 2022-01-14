# frozen_string_literal: true

module Users
  # Overrides to Devise's Passwords logic
  class PasswordsController < Devise::PasswordsController
    # GET /resource/password/new
    def new
      # super

      # Specify any classes for the <main> tag of the page
      @main_class = 'js-heroimage'
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
    # def update
    #   super
    # end

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
