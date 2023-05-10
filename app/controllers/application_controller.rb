# frozen_string_literal: true

# Base controller logic
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Look for template overrides before rendering
  before_action :prepend_view_paths

  before_action :set_locale

  after_action :store_location

  include GlobalHelpers
  include Pundit::Authorization
  helper_method GlobalHelpers.instance_methods

  # Reroute errors to the root_path or plans_path (if user is signed in) with an
  # appropriate message
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  rescue_from ActionController::InvalidAuthenticityToken, with: :ignore_error

  # rescue_from StandardError, with: :handle_server_error

  private

  def current_org
    current_user.org
  end

  def user_not_authorized
    if user_signed_in?
      # redirect_to plans_url, alert: _("You are not authorized to perform this action.")
      msg = _('You are not authorized to perform this action.')
      render_respond_to_format_with_error_message(msg, plans_url, 403, nil)
    else
      # redirect_to root_url, alert: _("You need to sign in or sign up before continuing.")
      msg = _('You need to sign in or sign up before continuing.')
      render_respond_to_format_with_error_message(msg, root_url, 401, nil)
    end
  end

  # Sets I18n locale for every request made
  def set_locale
    I18n.locale = current_locale
  end

  def current_locale
    @current_locale ||= (session[:locale].presence || I18n.default_locale)
  end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last
    # visited.
    unless ['/users/sign_in',
            '/users/sign_up',
            '/users/password',
            '/users/invitation/accept'].any? { |ur| request.fullpath.include?(ur) } \
    || request.xhr? # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  # ---------------------------------------------------------
  # Start DMPTool Customization
  #
  # Used by Devise after a user signs in
  def after_sign_in_path_for(_resource)
    # If not signed in send to the home page
    return root_path unless user_signed_in?
    # If signed in and not part of an Oauth2 workflow send to the Dashboard
    return plans_path if session['oauth-referer'].blank?

    # Continue with the Oauth2 workflow
    oauth_hash = ApplicationService.decrypt(payload: session['oauth-referer'])
    return plans_path unless oauth_hash.present? && oauth_hash['path'].present?

    oauth_hash['path']
  end

  # def after_sign_in_path_for(_resource)
  #   referer_path = URI(request.referer).path unless request.referer.nil?
  #   if from_external_domain? || referer_path.eql?(new_user_session_path) ||
  #      referer_path.eql?(new_user_registration_path) ||
  #      referer_path.nil?
  #     root_path
  #   else
  #     request.referer
  #   end
  # end
  #
  # def after_sign_up_path_for(_resource)
  #   referer_path = URI(request.referer).path unless request.referer.nil?
  #   if from_external_domain? ||
  #      referer_path.eql?(new_user_session_path) ||
  #      referer_path.nil?
  #     root_path
  #   else
  #     request.referer
  # end
  #
  #   def after_sign_in_error_path_for(_resource)
  #     (from_external_domain? ? root_path : request.referer || root_path)
  #   end
  #
  #   def after_sign_up_error_path_for(_resource)
  #     (from_external_domain? ? root_path : request.referer || root_path)
  #   end
  #
  # End DMPTool Customization
  # ---------------------------------------------------------

  def authenticate_admin!
    # currently if admin has any super-admin task, they can view the super-admin
    unless user_signed_in? && (current_user.can_add_orgs? ||
                               current_user.can_change_org? ||
                               current_user.can_super_admin?)
      redirect_to root_path
    end
  end

  def failure_message(obj, action = 'save')
    format(_('Unable to %{action} the %{object}. %{errors}'),
           object: obj_name_for_display(obj),
           action: action || 'save', errors: errors_for_display(obj))
  end

  def success_message(obj, action = 'saved')
    format(_('Successfully %{action} the %{object}.'), object: obj_name_for_display(obj), action: action || 'save')
  end

  def errors_for_display(obj)
    return '' unless obj.present? && obj.errors.any?

    msgs = obj.errors.full_messages.uniq.collect { |msg| "<li>#{msg}</li>" }
    "<ul>#{msgs.join}</li></ul>"
  end

  # rubocop:disable Metrics/AbcSize
  def obj_name_for_display(obj)
    display_name = {
      ApiClient: _('API client'),
      ExportedPlan: _('plan'),
      GuidanceGroup: _('guidance group'),
      Note: _('comment'),
      Org: _('organisation'),
      Perm: _('permission'),
      Pref: _('preferences'),
      User: obj == current_user ? _('profile') : _('user'),
      QuestionOption: _('question option'),
      ResearchOutput: _('Research Output')
    }
    if obj.respond_to?(:customization_of) && obj.send(:customization_of).present?
      display_name[:Template] = 'customization'
    end
    display_name[obj.class.name.to_sym] || obj.class.name.downcase || 'record'
  end
  # rubocop:enable Metrics/AbcSize

  # Override rails default render action to look for a branded version of a
  # template instead of using the default one. If no override exists, the
  # default version in ./app/views/[:controller]/[:action] will be used
  #
  # The path in the app/views/branded/ directory must match the the file it is
  # replacing. For example:
  #  app/views/branded/layouts/_header.html.erb -> app/views/layouts/_header.html.erb
  def prepend_view_paths
    prepend_view_path Rails.root.join('app', 'views', 'branded')
  end

  ##
  # Sign out of Shibboleth SP local session too.
  # -------------------------------------------------------------
  def after_sign_out_path_for(resource_or_scope)
    url = "#{Rails.configuration.x.shibboleth&.logout_url}#{root_url}"
    return url if Rails.configuration.x.shibboleth&.enabled

    super
  end
  # -------------------------------------------------------------

  def from_external_domain?
    if request.referer.present?
      referer = URI.parse(request.referer)
      home = URI.parse(root_url)
      referer.host != home.host
    else
      false
    end
  end

  def configure_permitted_parameters
    # DMPTool customization for new sign in / sign up
    devise_parameter_sanitizer.permit(:accept_invitation, keys: %i[firstname surname org_id])

    devise_parameter_sanitizer.permit(:sign_up, keys: %i[firstname surname org_id accept_terms])

    devise_parameter_sanitizer.permit(:account_update, keys: %i[firstname surname org_id
                                                                department_id language_id
                                                                password password_confirmation
                                                                current_password])
  end

  def render_not_found(exception)
    msg = _('Record Not Found') + ": #{exception.message}"
    render_respond_to_format_with_error_message(msg, root_url, 404, exception)
  end

  # Logs the error but then just redirects the user to the root path
  def ignore_error(exception)
    Rails.logger.error exception.message
    Rails.logger.error exception&.backtrace
    redirect_to root_path
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def handle_server_error(exception)
    # We don't care about general Pundit errors!
    unless exception.is_a?(Pundit::NotAuthorizedError) || Rails.env.development?
      # DMPTool customization to notify admin of 500 level error
      message = "#{ApplicationService.application_name} - #{exception.message}"
      message += '<br>----------------------------------------<br><br>'
      message += "Referrer: #{request&.referer}"
      message += '<br>----------------------------------------<br><br>'
      message += "Params: #{params.inspect}"
      message += '<br>----------------------------------------<br><br>'
      message += 'Backtrace:'
      message += exception&.backtrace&.to_s if exception.present? &&
                                               exception.respond_to?(:backtrace)
      UserMailer.notify_administrators(message).deliver_now
    end

    # If we are dev/test print the error to the console
    if Rails.env.development? || Rails.env.test?
      Rails.logger.debug { "#{exception.class.name} - #{exception&.message}" }
      Rails.logger.debug exception&.backtrace
    end

    render_respond_to_format_with_error_message(
      exception.message, (user_signed_in? ? plans_path : root_path), 500, exception
    )
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def render_respond_to_format_with_error_message(msg, url_or_path, http_status, exception)
    Rails.logger.error msg
    Rails.logger.error exception&.backtrace if exception.present? && exception.respond_to?(:backtrace)

    respond_to do |format|
      # Redirect use to the path and display the error message
      format.html { redirect_to url_or_path, alert: msg }
      # Render the JSON error message (using API V1)
      format.json do
        @payload = { errors: [msg] }
        render '/api/v2/error', status: http_status
      end
    end
  end
end
