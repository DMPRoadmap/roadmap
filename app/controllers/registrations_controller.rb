# frozen_string_literal: true

# Controller that handles user account creation and changes from the edit profile page
# rubocop:disable Layout/LineLength
class RegistrationsController < Devise::RegistrationsController
  #  include Dmptool::RegistrationsController

  # ********************************************************************************************
  # The DMPTool now handles Devise sign in in the /app/controllers/users/sessions_controller.rb
  # ********************************************************************************************

  # include OrgSelectable

  # def edit
  #   @user = current_user
  #   @prefs = @user.get_preferences(:email)
  #   @languages = Language.sorted_by_abbreviation
  #   @orgs = Org.order("name")
  #   @other_organisations = Org.where(is_other: true).pluck(:id)
  #   @identifier_schemes = IdentifierScheme.for_users.order(:name)
  #   @default_org = current_user.org

  #   msg = "No default preferences found (should be in dmproadmap.rb initializer)."
  #   flash[:alert] = msg unless @prefs
  # end

  # GET /resource
  def new
    #   oauth = { provider: nil, uid: nil }
    #   IdentifierScheme.for_users.each do |scheme|
    #     unless session["devise.#{scheme.name.downcase}_data"].nil?
    #       oauth = session["devise.#{scheme.name.downcase}_data"]
    #     end
    #   end

    #   @user = User.new

    #   # no oath, no provider or no uid - bail out
    #   return if oauth.nil? or oauth["provider"].nil? or oauth["uid"].nil?

    # Connect the new user with the identifier sent back by the OAuth provider
    # flash[:notice] = format(_("Please make a choice below. After linking your
    #                    details to a %{application_name} account,
    #                    you will be able to sign in directly with your
    #                    institutional credentials."), application_name: ApplicationService.application_name)
  end

  # POST /resource
  def create
    # oauth = { provider: nil, uid: nil }
    # IdentifierScheme.for_users.each do |scheme|
    #   oauth = session["devise.#{scheme.name.downcase}_data"] unless session["devise.#{scheme.name.downcase}_data"].nil?
    # end

    # blank_org = if Rails.configuration.x.application.restrict_orgs
    #               sign_up_params[:org_id]['id'].blank?
    #             else
    #               sign_up_params[:org_id].blank?
    #             end

    # if sign_up_params[:accept_terms].to_s == '0'
    #   redirect_to after_sign_up_error_path_for(resource),
    #               alert: _('You must accept the terms and conditions to register.')
    # elsif blank_org
    #   redirect_to after_sign_up_error_path_for(resource),
    #               alert: _('Please select an organisation from the list, or choose Other.')
    # else
    #   existing_user = User.where_case_insensitive('email', sign_up_params[:email]).first
    #   if existing_user.present?
    #     if existing_user.invitation_token.present? && !existing_user.accept_terms?
    #       # If the user is creating an account but they have an outstanding invitation, remember
    #       # any plans that were shared with the invitee so we can attach them to the new User record
    #       shared_plans = existing_user.roles
    #                                   .select(&:active?)
    #                                   .map { |role| { plan_id: role.plan_id, access: role.access } }
    #       existing_user.destroy
    #     else
    #       redirect_to after_sign_up_error_path_for(resource),
    #                   alert: _('That email address is already registered.')
    #       return
    #     end
    #   end

    #   # Handle the Org selection
    #   attrs = sign_up_params
    #   attrs = handle_org(attrs: attrs)

    #   # handle the language
    #   attrs[:language_id] = Language.default&.id unless attrs[:language_id].present?

    #   build_resource(attrs)

    #   # If the user is creating an account but they have an outstanding invitation, attach the shared
    #   # plan(s) to their new User record
    #   if shared_plans.present? && shared_plans.any?
    #     shared_plans.each do |role_hash|
    #       plan = Plan.find_by(id: role_hash[:plan_id])
    #       next unless plan.present?

    #       Role.create(plan: plan, user: resource, access: role_hash[:access], active: true)
    #     end
    #   end

    #   # Determine if reCAPTCHA is enabled and if so verify it
    #   use_recaptcha = Rails.configuration.x.recaptcha.enabled || false
    #   if (!use_recaptcha || verify_recaptcha(model: resource)) && resource.save
    #
    #     if resource.active_for_authentication?
    #       set_flash_message :notice, :signed_up if is_navigational_format?
    #       sign_up(resource_name, resource)
    #       UserMailer.welcome_notification(current_user).deliver_now
    #       if !oauth.nil? && !(oauth['provider'].nil? || oauth['uid'].nil?)
    #         prov = IdentifierScheme.find_by(name: oauth['provider'].downcase)
    #         # Until we enable ORCID signups
    #         if prov.present? && prov.name == 'shibboleth'
    #           Identifier.create(identifier_scheme: prov,
    #                             value: oauth['uid'],
    #                             attrs: oauth,
    #                             identifiable: resource)
    #           flash[:notice] = _('Welcome! You have signed up successfully with your
    #                               institutional credentials. You will now be able to access
    #                               your account with them.')
    #         end
    #       end
    #       respond_with resource, location: after_sign_up_path_for(resource)
    #     elsif is_navigational_format?
    #       set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
    #       respond_with resource, location: after_inactive_sign_up_path_for(resource)
    #     end
    #         #   else
    #     clean_up_passwords resource
    #     redirect_to after_sign_up_error_path_for(resource),
    #                 alert: _("Unable to create your account.#{errors_for_display(resource)}")

    #   end
    # end
  end

  def update
    # if user_signed_in?
    #   @prefs = @user.get_preferences(:email)
    #   @orgs = Org.order('name')
    #   @default_org = current_user.org
    #   @other_organisations = Org.where(is_other: true).pluck(:id)
    #   @identifier_schemes = IdentifierScheme.for_users.order(:name)
    #   @languages = Language.sorted_by_abbreviation
    #   if params[:skip_personal_details] == 'true'
    #     do_update_password(current_user, update_params)
    #   else
    #     do_update(needs_password?(current_user))
    #   end
    # else
    #   render(file: File.join(Rails.root, 'public/403.html'), status: 403, layout: false)
    # end
  end

  private

  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user)
    # user.email != update_params[:email] || update_params[:password].present?
  end
end
# rubocop:enable Layout/LineLength
