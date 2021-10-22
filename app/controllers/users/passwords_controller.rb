# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController

  # GET /resource/password/new
  def new
    # super

    # Specify any classes for the <main> tag of the page
    @main_class = "js-heroimage"
    self.resource = User.new
  end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  protected

  def after_resetting_password_path_for(resource)
   # super(resource)
   plans_path
  end

  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(resource_name)
    # super(resource_name)
    root_path
  end
end
