# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController

  include OrgSelectable

  include Dmptool::HomeController

  before_action :prepare_params

  before_action :configure_sign_up_params, only: [:create]

  before_action :configure_account_update_params, only: [:update]

  # This is a customization of the Devise action that displays the sign up form
  #
  # GET /resource/sign_up
  # def new
  #   super
  # end

  # This is a customization of the Devise action that creates a new user account
  # It was copied over verbatim. The modifications are noted below:
  #
  # POST /resource
  def create
    # super

    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length

      # Encrypt the form values and any validation errrors and stuff it into the session
      # for UI continuity since Devise wants to redirect everything
      @main_class = "js-heroimage"
      flash[:alert] = "Unable to create your account!"
      render :new
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(
      :sign_up, keys: [:accept_terms, :firstname, :language_id, :org_id, :surname,
                       org_attributes: [:name, :abbreviation, :contact_email, :contact_name,
                                        :links, :target_url, :is_other, :managed,:org_type]]
    )
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(
      :account_update, keys: [:firstname, :language_id, :surname]
    )
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    plans_path
  end

  # Set the Language to the one the user has selected
  def prepare_params
    unless I18n.locale.nil? || sign_up_params[:language_id].present?
      params[:user][:language_id] = Language.id_for(I18n.locale)
    end

    # Capitalize the first and last names
    params[:user][:firstname] = params[:user][:firstname]&.humanize
    params[:user][:surname] = params[:user][:surname]&.humanize

    # Convert the selected/specified Org name into attributes
    org_params = autocomplete_to_controller_params
    params[:user][:org_id] = org_params[:org_id] if org_params[:org_id].present?
    params[:user][:org_attributes] = org_params[:org_attributes] unless org_params[:org_id].present?
  end

end
