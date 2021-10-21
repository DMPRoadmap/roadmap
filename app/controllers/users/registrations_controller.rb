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
  def new
    # super
    email = crypto.decrypt_and_verify(
      session.fetch(:validation_token, ""), purpose: :sign_in
    )
    if email.present?
      resource = User.includes(:org, :identifiers)
                     .find_or_initialize_by(email: email)

      # If the user has no Org for some reason(because this is a new record), try to
      # determine what Org they belong to
      if resource.present? && resource.org_id.nil?
        email_domain = resource.email.split("@").last
        resource.org = org_from_email_domain(email_domain: email_domain)
      end
    end
    render_home_page
  end

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
      store_session_variable(
        name: :validation_token, payload: sign_up_params.to_h.to_json, purpose: :sign_in
      )
      store_session_variable(
        name: :errors, payload: errors_to_json(resource: resource), purpose: :sign_in
      )
      # Redirect to the Homepage which will fetch the session vars to repopulate the
      # user's entries
      redirect_to root_path
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

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  #
  def errors_to_json(resource:)
    out = []
    return out.to_json unless resource.present? && !resource.valid?

    out = resource.errors.full_messages.map do |err|
      if err.start_with?("Org")
        _("You must specify your Institution")
      elsif err.start_with?("Accept")
        _("You must accept the terms and conditions")
      else
        err
      end
    end
    out.flatten.uniq.to_json
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
