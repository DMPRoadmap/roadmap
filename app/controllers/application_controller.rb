class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Look for template overrides before rendering
  before_filter :prepend_view_paths


  include GlobalHelpers
  include Pundit
  helper_method GlobalHelpers.instance_methods


  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def user_not_authorized
    if user_signed_in?
      redirect_to plans_url, alert: _('You are not authorized to perform this action.')
    else
      redirect_to root_url, alert: _('You need to sign in or sign up before continuing.')
    end
  end

  before_filter :set_gettext_locale

  after_filter :store_location

  # Sets FastGettext locale for every request made
  def set_gettext_locale
    FastGettext.locale = session[:locale] || FastGettext.default_locale
  end

  # PATCH /locale/:locale REST method
  def set_locale_session
    if FastGettext.default_available_locales.include?(params[:locale])
      session[:locale] = params[:locale]
    end
    redirect_to(request.referer || root_path) #redirects the user to URL where she/he was when the request to this resource was made or root if none is encountered
  end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    unless ["/users/sign_in",
            "/users/sign_up",
            "/users/password",
            "/users/invitation/accept",
           ].any? { |ur| request.fullpath.include?(ur) } \
    or request.xhr? # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    referer_path = URI(request.referer).path unless request.referer.nil? or nil
    if from_external_domain? || referer_path.eql?(new_user_session_path) || referer_path.eql?(new_user_registration_path) || referer_path.nil?
      root_path
    else
      request.referer
    end
  end

  def after_sign_up_path_for(resource)
    referer_path = URI(request.referer).path unless request.referer.nil? or nil
    if from_external_domain? || referer_path.eql?(new_user_session_path) || referer_path.nil?
      root_path
    else
      request.referer
    end
  end

  def after_sign_in_error_path_for(resource)
    (from_external_domain? ? root_path : request.referer || root_path)
  end

  def after_sign_up_error_path_for(resource)
    (from_external_domain? ? root_path : request.referer || root_path)
  end

  def authenticate_admin!
    # currently if admin has any super-admin task, they can view the super-admin
    redirect_to root_path unless user_signed_in? && (current_user.can_add_orgs? || current_user.can_change_org? || current_user.can_super_admin?)
  end

  def failed_create_error(obj, obj_name)
    "#{_('Could not create your %{o}.') % {o: obj_name}} #{errors_to_s(obj)}"
  end

  def failed_update_error(obj, obj_name)
    "#{_('Could not update your %{o}.') % {o: obj_name}} #{errors_to_s(obj)}"
  end

  def failed_destroy_error(obj, obj_name)
    "#{_('Could not delete the %{o}.') % {o: obj_name}} #{errors_to_s(obj)}"
  end

  def success_message(obj_name, action)
    "#{_('Successfully %{action} your %{object}.') % {object: obj_name, action: action}}"
  end

  # Check whether the string is a valid array of JSON objects
  def is_json_array_of_objects?(string)
    if string.present?
      begin
        json = JSON.parse(string)
        return (json.is_a?(Array) && json.all?{ |o| o.is_a?(Hash) })
      rescue JSON::ParserError
        return false
      end
    end
  end

  private
    # Override rails default render action to look for a branded version of a
    # template instead of using the default one. If no override exists, the
    # default version in ./app/views/[:controller]/[:action] will be used
    #
    # The path in the app/views/branded/ directory must match the the file it is
    # replacing. For example:
    #  app/views/branded/layouts/_header.html.erb -> app/views/layouts/_header.html.erb
    def prepend_view_paths
      prepend_view_path "app/views/branded"
    end

    def errors_to_s(obj)
      if obj.errors.count > 0
        msg = "<br />"
        obj.errors.each do |e,m|
          if m.include?('empty') || m.include?('blank')
            msg += "#{_(e)} - #{_(m)}<br />"
          else
            msg += "'#{obj[e]}' - #{_(m)}<br />"
          end
        end
        msg
      end
    end

    ##
    # Sign out of Shibboleth SP local session too.
    # -------------------------------------------------------------
    def after_sign_out_path_for(resource_or_scope)
      if Rails.application.config.shibboleth_enabled
        return Rails.application.config.shibboleth_logout_url + root_url
        super
      else
        super
      end
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
end
