class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Look for template overrides before rendering
  before_filter :prepend_view_paths

  include GlobalHelpers
  include Pundit
  helper_method GlobalHelpers.instance_methods

  # Override build_footer method in ActiveAdmin::Views::Pages
  require 'active_admin_views_pages_base.rb'

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def user_not_authorized
    redirect_to root_url, alert: _('You need to sign in or sign up before continuing.')
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
    redirect_to root_path
  end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    if (request.fullpath != "/users/sign_in" && \
			 request.fullpath != "/users/sign_up" && \
			 request.fullpath != "/users/password" && \
            request.fullpath != "/users/sign_up?nosplash=true" && \
			 !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def after_sign_up_path_for(resource)
    session[:previous_url] || root_path
  end

  def after_sign_in_error_path_for(resource)
    session[:previous_url] || root_path
  end

  def after_sign_up_error_path_for(resource)
    session[:previous_url] || root_path
  end

  def authenticate_admin!
    # currently if admin has any super-admin task, they can view the super-admin
    redirect_to root_path unless user_signed_in? && (current_user.can_add_orgs? || current_user.can_change_org? || current_user.can_super_admin?)
  end

  def get_plan_list_columns
    if user_signed_in?
      @selected_columns = current_user.settings(:plan_list).columns

      # handle settings saved and stored using an older version of the settings gem
      if @selected_columns.kind_of? Hash
        unless @selected_columns['elements'].nil?
          @selected_columns = @selected_columns['elements'].collect{|k,v| puts "#{k} - #{v}"; k}
        end
      end
      
      # If the settings are missing or stored in the wrong format for some reason 
      # then use the defaults columns
      @selected_columns = Settings::PlanList::DEFAULT_COLUMNS if @selected_columns.empty?
      
      @all_columns = Settings::PlanList::ALL_COLUMNS
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
end
